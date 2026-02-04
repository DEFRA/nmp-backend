
CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodFebNLimit]
    @OrganicManureID INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,
        @CropYear INT,
        @SowingDate DATE,
        @ApplicationDate DATE,
        @ManureTypeID INT,
        @SoilTypeID INT,
        @N DECIMAL(18,3),
        @ApplicationRate DECIMAL(18,3),

        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        @IsFieldInEngland BIT = 0,
        @IsFieldInWelsh BIT = 0,
        @IsWithinNVZ BIT = 0,
        @RegisteredOrganicProducer BIT = 0,
        @IsHighRanManures BIT = 0,

        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,

        @YearCycleStart DATE,
        @YearCycleEnd DATE,

        @ClosedStartDate DATE,
        @ClosedEndDate DATE,
        @FebEnd DATE,

        @IsWithinClosedPeriod BIT = 0,
        @IsWithinClosedPeriodToFeb BIT = 0,

        @TotalClosedPeriodN DECIMAL(18,3) = 0,

        @IsAllowedCrop BIT = 0,
        @IsTotalClosedPeriodNAboveLimit BIT = 0;

    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = om.ManagementPeriodID,
        @ApplicationDate    = CAST(om.ApplicationDate AS DATE),
        @ManureTypeID       = om.ManureTypeID,
        @N                  = om.N,
        @ApplicationRate    = ISNULL(om.ApplicationRate,0)
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureID;

    --------------------------------------------------------------------
    -- 2) Crop & Field
    --------------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;

    SELECT
        @FieldID    = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @CropYear   = c.Year,
        @SowingDate = CAST(c.SowingDate AS DATE)
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 3) Allowed Crops
    --------------------------------------------------------------------
    SET @IsAllowedCrop =
        CASE WHEN @CropTypeID IN (20,60,73,74) THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 4) Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID  = f.SoilTypeID,
        @IsWithinNVZ = ISNULL(f.IsWithinNVZ,0),
        @FarmID      = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 5) Farm
    --------------------------------------------------------------------
    SELECT
        @CountryID = fm.CountryID,
        @RegisteredOrganicProducer = ISNULL(fm.RegisteredOrganicProducer,0)
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWelsh   = 1;

    --------------------------------------------------------------------
    -- 6) High RAN
    --------------------------------------------------------------------
    IF @ManureTypeID IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;

    --------------------------------------------------------------------
    -- 7) Date helpers
    --------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @SowMMDD =
        CASE WHEN @SowingDate IS NULL THEN NULL
             ELSE MONTH(@SowingDate)*100 + DAY(@SowingDate) END;

    --------------------------------------------------------------------
    -- 8) Perennial flags
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = ISNULL(ctl.IsPerennial,0)
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    IF EXISTS (
        SELECT 1 FROM Crops c2
        WHERE c2.FieldID = @FieldID
          AND c2.Year < @CropYear
    )
        SET @HasPriorYearPlantings = 1;

    --------------------------------------------------------------------
    -- 9) Year Cycle (Aug → Jul)
    --------------------------------------------------------------------
    SET @AppYear = YEAR(@ApplicationDate);

    IF @AppMMDD < 801
        SET @YearCycleStart = DATEFROMPARTS(@AppYear-1,8,1);
    ELSE
        SET @YearCycleStart = DATEFROMPARTS(@AppYear,8,1);

    --------------------------------------------------------------------
    -- 10) CLOSED PERIOD LOGIC
    --------------------------------------------------------------------
    IF @CropTypeID = 140
    BEGIN
        -- GRASS
        IF @SoilTypeID IN (0,1)
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
            SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
        ELSE
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,15);
            SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
        END
    END
    ELSE
    BEGIN
        -- NON-GRASS
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

        -- PRIOR YEAR PERENNIAL OVERRIDE
        IF @IsPerennial = 1 AND @HasPriorYearPlantings = 1
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
            SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
    END

    --------------------------------------------------------------------
    -- 11) Inside Closed Period
    --------------------------------------------------------------------
    SET @IsWithinClosedPeriod =
        CASE WHEN @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
             THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 12) FEB END (YEAR AFTER CLOSED START)
    --------------------------------------------------------------------
    DECLARE @FebYear INT = YEAR(@ClosedStartDate) + 1;

    SET @FebEnd =
        CASE WHEN DAY(EOMONTH(DATEFROMPARTS(@FebYear,2,1))) = 29
             THEN DATEFROMPARTS(@FebYear,2,29)
             ELSE DATEFROMPARTS(@FebYear,2,28) END;

    IF @IsWithinClosedPeriod = 1
       AND @ApplicationDate <= @FebEnd
        SET @IsWithinClosedPeriodToFeb = 1;

    --------------------------------------------------------------------
    -- 13) TOTAL N × RATE (Closed → Feb)
    --------------------------------------------------------------------
    SELECT
        @TotalClosedPeriodN =
            ISNULL(SUM(om2.N * ISNULL(om2.ApplicationRate,0)),0)
    FROM OrganicManures om2
    WHERE om2.ManagementPeriodID = @ManagementPeriodID
      AND om2.ApplicationDate BETWEEN @ClosedStartDate AND @FebEnd;

    SET @IsTotalClosedPeriodNAboveLimit =
        CASE WHEN @IsAllowedCrop = 1 AND @TotalClosedPeriodN > 150
             THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 14) FINAL OUTPUT
    --------------------------------------------------------------------
    SELECT
        @OrganicManureID AS OrganicManureID,
        @ManagementPeriodID AS ManagementPeriodID,
        @CropID AS CropID,
        @FieldID AS FieldID,
        @FarmID AS FarmID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWelsh AS IsFieldInWelsh,
        @IsWithinNVZ AS IsWithinNVZ,
        @RegisteredOrganicProducer AS RegisteredOrganicProducer,

        @CropTypeID AS CropTypeID,
        @SoilTypeID AS SoilTypeID,

        @ApplicationDate AS ApplicationDate,
        @ClosedStartDate AS ClosedPeriodStart,
        @ClosedEndDate AS ClosedPeriodEnd,
        @FebEnd AS FebEnd,

        @IsHighRanManures AS IsHighRanManures,
        @IsWithinClosedPeriod AS InsideClosedPeriod,
        @IsWithinClosedPeriodToFeb AS InsideClosedPeriodToFeb,

        (@N * @ApplicationRate) AS CurrentManureN,
        @TotalClosedPeriodN AS TotalClosedPeriodN,

        @IsAllowedCrop AS IsAllowedCrop,
        @IsTotalClosedPeriodNAboveLimit AS IsTotalClosedPeriodNAboveLimit;
END;