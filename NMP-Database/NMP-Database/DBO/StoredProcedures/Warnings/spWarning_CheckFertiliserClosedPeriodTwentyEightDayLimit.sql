



CREATE PROCEDURE [dbo].[spWarning_CheckFertiliserClosedPeriodTwentyEightDayLimit]
    @FertiliserID INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLE DECLARATIONS
    --------------------------------------------------------------------
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
        @Nitrogen DECIMAL(18,3),

        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNVZ BIT = 0,

        @IsCropTypeAllowed BIT = 0,
        @IsInsideClosedPeriod BIT = 0,
        @IsCurrentNAbove50 BIT = 0,
        @IsTotalNAbove100 BIT = 0,
        @IsPreviousApplicationWithin28Days BIT = 0,

        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,

        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,

        @YearCycleStart DATE,
        @YearCycleEnd DATE,

        @TotalClosedPeriodN DECIMAL(18,3) = 0;

    --------------------------------------------------------------------
    -- 1) Load Fertiliser
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = f.ManagementPeriodID,
        @ApplicationDate = f.ApplicationDate,
        @Nitrogen = f.N
    FROM FertiliserManures f
    WHERE f.ID = @FertiliserID;

    --------------------------------------------------------------------
    -- 2) Load CropID
    --------------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;

    --------------------------------------------------------------------
    -- 3) Load Crop
    --------------------------------------------------------------------
    SELECT
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 4) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmID = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 5) Load Farm
    --------------------------------------------------------------------
    SELECT @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    --------------------------------------------------------------------
    -- 6) Country Flags
    --------------------------------------------------------------------
    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWales   = 1;

    --------------------------------------------------------------------
    -- 7) Allowed CropTypes
    --------------------------------------------------------------------
    IF @CropTypeID IN (43,41,189,44,194,195,61,62,63,64,70,78,92,93)
         SET @IsCropTypeAllowed = 1;
    ELSE SET @IsCropTypeAllowed = 0;

    --------------------------------------------------------------------
    -- 8) Prep Date Parts
    --------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);

    IF @SowingDate IS NOT NULL
         SET @SowMMDD = MONTH(@SowingDate)*100 + DAY(@SowingDate);
    ELSE SET @SowMMDD = NULL;

    --------------------------------------------------------------------
    -- 9) Perennial Check
    --------------------------------------------------------------------
    SELECT TOP 1 @IsPerennial =
        CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    --------------------------------------------------------------------
    -- 10) Prior-Year Plantings
    --------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM Crops WHERE FieldID=@FieldID AND Year < YEAR(@ApplicationDate))
        SET @HasPriorYearPlantings = 1;

    --------------------------------------------------------------------
    -- 11) Year Cycle Logic (1 Aug → 31 Jul)
    --------------------------------------------------------------------
    SET @AppYear = YEAR(@ApplicationDate);

    IF @AppMMDD < 801
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@AppYear - 1, 8, 1);
        SET @YearCycleEnd   = DATEFROMPARTS(@AppYear, 7, 31);
    END
    ELSE
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@AppYear, 8, 1);
        SET @YearCycleEnd   = DATEFROMPARTS(@AppYear + 1, 7, 31);
    END;

    --------------------------------------------------------------------
    -- 12) CLOSED PERIOD LOGIC (FERTILISER-SPECIFIC)
    --------------------------------------------------------------------
    SET @ClosedPeriodStart = NULL;
    SET @ClosedPeriodEnd   = NULL;

    IF @CropTypeID = 140   -- GRASS (special logic)
    BEGIN
        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,15);
        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
    END
    ELSE
    BEGIN
        -- NON-GRASS
        IF @IsPerennial = 0
        BEGIN
            IF @SoilTypeID IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                ELSE
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);

                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
            END
            ELSE
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
            END
        END
        ELSE
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
    END

    --------------------------------------------------------------------
    -- 13) Is Application Inside Closed Period?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd
        SET @IsInsideClosedPeriod = 1;

    --------------------------------------------------------------------
    -- 14) Current N > 50?
    --------------------------------------------------------------------
    IF @Nitrogen > 50 SET @IsCurrentNAbove50 = 1;

    --------------------------------------------------------------------
    -- 15) SUM N for all fertiliser applications inside closed period
    --------------------------------------------------------------------
    SELECT @TotalClosedPeriodN =
        SUM(fm2.N)
    FROM FertiliserManures fm2
    WHERE fm2.ManagementPeriodID = @ManagementPeriodID
      AND fm2.ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd;

    IF @TotalClosedPeriodN IS NULL SET @TotalClosedPeriodN = 0;

    IF @TotalClosedPeriodN > 100
        SET @IsTotalNAbove100 = 1;

    --------------------------------------------------------------------
    -- 16) Previous fertiliser within 28 days AND inside closed period
    --------------------------------------------------------------------
    SELECT TOP 1 @IsPreviousApplicationWithin28Days = 1
    FROM FertiliserManures fm3
    WHERE fm3.ManagementPeriodID = @ManagementPeriodID
      AND fm3.ID <> @FertiliserID
      AND fm3.ApplicationDate BETWEEN DATEADD(DAY,-27,@ApplicationDate) AND @ApplicationDate
      AND fm3.ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd;

    --------------------------------------------------------------------
    -- 17) FINAL RETURN
    --------------------------------------------------------------------
    SELECT
        @FertiliserID AS FertiliserID,
        @FieldID AS FieldID,
        @CropID AS CropID,
        @CropTypeID AS CropTypeID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNVZ AS IsWithinNVZ,

        @IsCropTypeAllowed AS IsCropTypeAllowed,
        @IsInsideClosedPeriod AS IsInsideClosedPeriod,

        @IsCurrentNAbove50 AS IsCurrentNAbove50,
        @TotalClosedPeriodN AS TotalClosedPeriodN,
        @IsTotalNAbove100 AS IsTotalNAbove100,
        @IsPreviousApplicationWithin28Days AS IsPreviousApplicationWithin28Days,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd;
END