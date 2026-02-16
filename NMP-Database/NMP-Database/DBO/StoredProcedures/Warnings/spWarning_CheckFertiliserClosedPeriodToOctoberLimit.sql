



CREATE PROCEDURE [dbo].[spWarning_CheckFertiliserClosedPeriodToOctoberLimit]
    @FertiliserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------
    -- DECLARE VARIABLES
    -------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,

        @ApplicationDate DATETIME,
        @SowingDate DATETIME,
        @SoilTypeID INT,
        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        -- Flags
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNVZ BIT = 0,
        @IsInsideClosedPeriodToOctober BIT = 0,
        @IsCropTypeAllowed BIT = 0,

        -- Date helpers
        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,
        @YearCycleStart DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @Oct31 DATE,

        -- Nitrogen totals
        @TotalClosedPeriodN DECIMAL(18,3) = 0;


    -------------------------------------------------------------
    -- 1) Load fertiliser
    -------------------------------------------------------------
    SELECT
        @ManagementPeriodID = f.ManagementPeriodID,
        @ApplicationDate = f.ApplicationDate
    FROM FertiliserManures f
    WHERE f.ID = @FertiliserID;

    -------------------------------------------------------------
    -- 2) MP → Crop
    -------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;

    -------------------------------------------------------------
    -- 3) Load crop
    -------------------------------------------------------------
    SELECT
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropID;

    -------------------------------------------------------------
    -- 4) Load field
    -------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @FarmID = f.FarmID,
        @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END
    FROM Fields f
    WHERE f.ID = @FieldID;

    -------------------------------------------------------------
    -- 5) Load farm
    -------------------------------------------------------------
    SELECT
        @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWales = 1;

    -------------------------------------------------------------
    -- 6) CropType allowed (only cropTypeID = 20)
    -------------------------------------------------------------
    IF @CropTypeID = 20 SET @IsCropTypeAllowed = 1;

    -------------------------------------------------------------
    -- 7) Perennial flag
    -------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    -------------------------------------------------------------
    -- 8) Prior-year perennial plantings?
    -------------------------------------------------------------
    IF EXISTS (
        SELECT 1 
        FROM Crops c2 
        INNER JOIN CropTypeLinkings ctl2 ON c2.CropTypeID = ctl2.CropTypeID
        WHERE c2.FieldID = @FieldID
          AND c2.Year < YEAR(@ApplicationDate)
          AND ctl2.IsPerennial = 1
    )
        SET @HasPriorYearPlantings = 1;

    -------------------------------------------------------------
    -- 9) Date helpers
    -------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @SowMMDD = CASE WHEN @SowingDate IS NULL THEN NULL
                        ELSE MONTH(@SowingDate)*100 + DAY(@SowingDate) END;

    SET @AppYear = YEAR(@ApplicationDate);

    IF @AppMMDD < 801
        SET @YearCycleStart = DATEFROMPARTS(@AppYear-1,8,1);
    ELSE
        SET @YearCycleStart = DATEFROMPARTS(@AppYear,8,1);

    -------------------------------------------------------------
    -- 10) FULL CLOSED PERIOD LOGIC (Grass, Non-perennial, Perennial)
    -------------------------------------------------------------
    SET @ClosedPeriodStart = NULL;
    SET @ClosedPeriodEnd   = NULL;

    IF @CropTypeID = 140   -- GRASS
    BEGIN
        IF @SoilTypeID IN (0,1)
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
        ELSE
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,15);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
        END
    END
    ELSE
    BEGIN
        IF @IsPerennial = 0   -- NON PERENNIAL
        BEGIN
            IF @SoilTypeID IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                ELSE
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);

                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
            END
            ELSE
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
        ELSE    -- PERENNIAL
        BEGIN
            IF @SoilTypeID IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                ELSE
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);

                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);

                -- PRIOR YEAR PERENNIAL OVERRIDE
                IF @HasPriorYearPlantings = 1
                BEGIN
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                END
            END
            ELSE
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
    END

    -------------------------------------------------------------
    -- 11) Limit closed period end to 31 October ONLY for this rule
    -------------------------------------------------------------
    SET @Oct31 = DATEFROMPARTS(YEAR(@ClosedPeriodStart), 10, 31);
    SET @ClosedPeriodEnd = @Oct31;

    -------------------------------------------------------------
    -- 12) Check if inside closed period
    -------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd
        SET @IsInsideClosedPeriodToOctober = 1;

    -------------------------------------------------------------
    -- 13) SUM N of all fertilisers in closed period
    -------------------------------------------------------------
    SELECT
        @TotalClosedPeriodN = SUM(f2.N)
    FROM FertiliserManures f2
    WHERE f2.ManagementPeriodID = @ManagementPeriodID
      AND f2.ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd;

    IF @TotalClosedPeriodN IS NULL SET @TotalClosedPeriodN = 0;

    -------------------------------------------------------------
    -- 14) OUTPUT
    -------------------------------------------------------------
    SELECT
        @FertiliserID AS FertiliserID,
        @FieldID AS FieldID,
        @CropID AS CropID,
        @CropTypeID AS CropTypeID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNVZ AS IsWithinNVZ,

        @IsInsideClosedPeriodToOctober AS IsInsideClosedPeriodToOctober,
        @IsCropTypeAllowed AS IsCropTypeAllowed,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,

        @TotalClosedPeriodN AS TotalClosedPeriodNitrogen,
        CASE WHEN @TotalClosedPeriodN > 30 THEN 1 ELSE 0 END AS IsTotalNAbove30;
END;