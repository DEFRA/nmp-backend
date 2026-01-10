


CREATE PROCEDURE [dbo].[spWarning_CheckFertiliserClosedPeriodOctoberGrassHighN]
    @FertiliserID INT
AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------------------------
    -- VARIABLE DECLARATION
    ----------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,
        @SoilTypeID INT,

        @ApplicationDate DATETIME,
        @SowingDate DATETIME,

        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,

        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNVZ BIT = 0,

        @IsGrassCropType BIT = 0,
        @IsCurrentNAbove40 BIT = 0,
        @IsInsideClosedPeriodToOct BIT = 0,
        @IsTotalNAbove80 BIT = 0,

        @ClosedStartDate DATE,
        @ClosedEndDate DATE,
        @OctoberEnd DATE,

        @TotalN DECIMAL(18,3) = 0,

        @IsPerennial BIT = 0,
        @HasPriorPlantings BIT = 0;


    ----------------------------------------------------------------------
    -- 1) Load Fertiliser
    ----------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = f.ManagementPeriodID,
        @ApplicationDate = f.ApplicationDate
    FROM FertiliserManures f
    WHERE f.ID = @FertiliserID;

    ----------------------------------------------------------------------
    -- 2) MP → Crop
    ----------------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;

    ----------------------------------------------------------------------
    -- 3) Load Crop
    ----------------------------------------------------------------------
    SELECT 
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropID;

    ----------------------------------------------------------------------
    -- 4) Grass CropType = 140
    ----------------------------------------------------------------------
    IF @CropTypeID = 140 SET @IsGrassCropType = 1;

    ----------------------------------------------------------------------
    -- 5) Load Field
    ----------------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmID = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;

    ----------------------------------------------------------------------
    -- 6) Load Farm
    ----------------------------------------------------------------------
    SELECT @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    ----------------------------------------------------------------------
    -- 7) England / Wales flags
    ----------------------------------------------------------------------
    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWales = 1;

    ----------------------------------------------------------------------
    -- 8) Prepare date helpers
    ----------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);

    IF @SowingDate IS NOT NULL
        SET @SowMMDD = MONTH(@SowingDate)*100 + DAY(@SowingDate);

    SET @AppYear = YEAR(@ApplicationDate);

    ----------------------------------------------------------------------
    -- 9) CLOSED PERIOD LOGIC (grass + perennial rules same as before)
    ----------------------------------------------------------------------
    SET @ClosedStartDate = NULL;
    SET @ClosedEndDate = NULL;

    IF @CropTypeID = 140  -- Grass
    BEGIN
        IF @SoilTypeID IN (0,1)  -- sandy / shallow soils
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(@AppYear,9,1);
            SET @ClosedEndDate   = DATEFROMPARTS(@AppYear,12,31);
        END
        ELSE
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(@AppYear,10,15);
            SET @ClosedEndDate   = DATEFROMPARTS(@AppYear+1,1,31);
        END
    END
    ELSE
    BEGIN
        -- Non-grass perennial + non-perennial rules (same as your full logic)
        DECLARE @YearCycleStart DATE;

        IF @AppMMDD < 801
            SET @YearCycleStart = DATEFROMPARTS(@AppYear-1,8,1);
        ELSE
            SET @YearCycleStart = DATEFROMPARTS(@AppYear,8,1);

        IF @IsPerennial = 0
        BEGIN
            IF @SoilTypeID IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                ELSE
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);

                SET @ClosedEndDate = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
            END
            ELSE
            BEGIN
                SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
        ELSE
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
            SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
    END;

    ----------------------------------------------------------------------
    -- October End
    ----------------------------------------------------------------------
    SET @OctoberEnd = DATEFROMPARTS(YEAR(@ClosedStartDate),10,31);

    ----------------------------------------------------------------------
    -- 10) Current Application N > 40?
    ----------------------------------------------------------------------
    DECLARE @CurrentN DECIMAL(18,3);
    SELECT @CurrentN = f.N FROM FertiliserManures f WHERE f.ID = @FertiliserID;

    IF @CurrentN > 40 SET @IsCurrentNAbove40 = 1;

    ----------------------------------------------------------------------
    -- 11) Inside closed period to 31 October?
    ----------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedStartDate AND @OctoberEnd
        SET @IsInsideClosedPeriodToOct = 1;

    ----------------------------------------------------------------------
    -- 12) Total N of all fertilisers in same MP inside closed period → Oct 31
    ----------------------------------------------------------------------
    SELECT @TotalN = SUM(f2.N)
    FROM FertiliserManures f2
    WHERE f2.ManagementPeriodID = @ManagementPeriodID
      AND f2.ApplicationDate BETWEEN @ClosedStartDate AND @OctoberEnd;

    IF @TotalN > 80 SET @IsTotalNAbove80 = 1;

    ----------------------------------------------------------------------
    -- FINAL OUTPUT
    ----------------------------------------------------------------------
    SELECT
        @FertiliserID AS FertiliserID,
        @CropID AS CropID,
        @FieldID AS FieldID,
        @CropTypeID AS CropTypeID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNVZ AS IsWithinNVZ,

        @ClosedStartDate AS ClosedPeriodStart,
        @ClosedEndDate AS ClosedPeriodEnd,
        @OctoberEnd AS OctoberEnd,

        @IsGrassCropType AS IsGrassCropType,
        @IsInsideClosedPeriodToOct AS IsInsideClosedPeriodToOctober,
        @IsCurrentNAbove40 AS IsCurrentNAbove40,
        @TotalN AS TotalClosedPeriodN,
        @IsTotalNAbove80 AS IsTotalClosedPeriodNAbove80;
END;