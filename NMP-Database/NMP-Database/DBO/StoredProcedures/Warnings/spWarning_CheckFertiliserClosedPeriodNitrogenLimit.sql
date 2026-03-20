


CREATE   PROCEDURE [dbo].[spWarning_CheckFertiliserClosedPeriodNitrogenLimit]
    @FertiliserID INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES (alphabet-only)
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @CropTypeID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @SoilTypeID INT,
        @SowingDate DATETIME,
        @ApplicationDate DATETIME,

        -- flags
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNVZ BIT = 0,
        @IsApplicationInsideClosedPeriod BIT = 0,
        @IsAllowedCropType BIT = 0,
        @IsTotalNAboveLimit BIT = 0,

        -- perennials / prior-year checks
        @IsPerennialCurrent BIT = 0,
        @HasPriorYearPerennial BIT = 0,

        -- totals / limits
        @TotalFertiliserN DECIMAL(18,3) = 0,
        @MaxNitrogenRate DECIMAL(18,3) = 0,

        -- date helpers
        @AppYear INT,
        @AppMMDD INT,
        @SowMMDD INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE;


    --------------------------------------------------------------------
    -- 1) LOAD FERTILISER RECORD
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = fm.ManagementPeriodID,
        @ApplicationDate    = fm.ApplicationDate
    FROM FertiliserManures fm
    WHERE fm.ID = @FertiliserID;

    --------------------------------------------------------------------
    -- 2) MANAGEMENT PERIOD -> CROP
    --------------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;

    --------------------------------------------------------------------
    -- 3) LOAD CROP
    --------------------------------------------------------------------
    SELECT
        @FieldID    = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 4) LOAD FIELD
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmID = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 5) LOAD FARM
    --------------------------------------------------------------------
    SELECT
        @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    --------------------------------------------------------------------
    -- 6) COUNTRY FLAGS
    --------------------------------------------------------------------
    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWales   = 1;

    --------------------------------------------------------------------
    -- 7) ALLOWED CROP TYPES FOR THIS CHECK: 60,73,74
    --------------------------------------------------------------------
    IF @CropTypeID IN (60,73,74)
        SET @IsAllowedCropType = 1;
    ELSE
    BEGIN
        SET @IsAllowedCropType = 0;

        SELECT
            @FertiliserID AS FertiliserID,
            @FieldID AS FieldID,
            @CropID AS CropID,
            @CropTypeID AS CropTypeID,
            @IsFieldInEngland AS IsFieldInEngland,
            @IsFieldInWales AS IsFieldInWales,
            @IsWithinNVZ AS IsWithinNVZ,
            @IsAllowedCropType AS IsAllowedCropType;

        RETURN;
    END

    --------------------------------------------------------------------
    -- 8) MAX N BY CROPTYPE
    --------------------------------------------------------------------
    IF @CropTypeID = 60 SET @MaxNitrogenRate = 50;
    IF @CropTypeID = 73 SET @MaxNitrogenRate = 40;
    IF @CropTypeID = 74 SET @MaxNitrogenRate = 40;

    --------------------------------------------------------------------
    -- 9) YEAR CYCLE (1 Aug -> 31 Jul) for deriving year parts
    --------------------------------------------------------------------
    SET @AppYear = YEAR(@ApplicationDate);
    SET @AppMMDD = MONTH(@ApplicationDate) * 100 + DAY(@ApplicationDate);

    IF @AppMMDD < 801
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@AppYear - 1, 8, 1);
        SET @YearCycleEnd   = DATEFROMPARTS(@AppYear, 7, 31);
    END
    ELSE
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@AppYear, 8, 1);
        SET @YearCycleEnd   = DATEFROMPARTS(@AppYear + 1, 7, 31);
    END

    --------------------------------------------------------------------
    -- 10) PERENNIAL FLAG for CURRENT crop
    --------------------------------------------------------------------
    SELECT TOP (1)
        @IsPerennialCurrent = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    IF @IsPerennialCurrent IS NULL SET @IsPerennialCurrent = 0;

    --------------------------------------------------------------------
    -- 11) Has any PRIOR-YEAR perennial crop on same field?
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops cprev
        INNER JOIN CropTypeLinkings ctlprev ON ctlprev.CropTypeID = cprev.CropTypeID
        WHERE cprev.FieldID = @FieldID
          AND cprev.Year < (SELECT ISNULL(c.Year,0) FROM Crops c WHERE c.ID = @CropID)
          AND ISNULL(ctlprev.IsPerennial,0) = 1
    )
        SET @HasPriorYearPerennial = 1;
    ELSE
        SET @HasPriorYearPerennial = 0;

    --------------------------------------------------------------------
    -- 12) PREP SOWING MMDD
    --------------------------------------------------------------------
    IF @SowingDate IS NOT NULL
        SET @SowMMDD = MONTH(@SowingDate) * 100 + DAY(@SowingDate);
    ELSE
        SET @SowMMDD = NULL;

    --------------------------------------------------------------------
    -- 13) CLOSED PERIOD DETERMINATION (fertiliser-specific rules)
    --
    -- Rules implemented exactly as described:
    --  - Prior-year perennial -> 1 Sep to 15 Jan (regardless of soil)
    --  - Current grass (140) -> 15 Sep to 15 Jan
    --  - Else -> branches for perennial/non-perennial and soil; most branches
    --    resolve to 1 Sep to 15 Jan (implemented explicitly)
    --------------------------------------------------------------------
    SET @ClosedPeriodStart = NULL;
    SET @ClosedPeriodEnd   = NULL;

    -- 13.a) Prior-year perennial forces 1 Sep - 15 Jan
    IF @HasPriorYearPerennial = 1
    BEGIN
        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 15);
    END
    ELSE
    BEGIN
        -- 13.b) If current crop is grass (140) -> 15 Sep to 15 Jan
        IF @CropTypeID = 140
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 15);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 15);
        END
        ELSE
        BEGIN
            -- 13.c) Non-grass / general rules
            -- Handle seams where soiltype matters. Based on your descriptions,
            -- most cases result in 1 Sep - 15 Jan; implement branches and set 1 Sep
            IF @IsPerennialCurrent = 0
            BEGIN
                -- non-perennial
                IF @SoilTypeID IN (0,1)
                BEGIN
                    -- According to your spec: both sowing >=16 Sep OR sowing unknown
                    -- and sowing <=15 Sep paths lead to 1 Sep - 15 Jan
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 15);
                END
                ELSE
                BEGIN
                    -- other soils -> 1 Sep - 15 Jan
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 15);
                END
            END
            ELSE
            BEGIN
                -- current perennial: similar outcome per your spec
                IF @SoilTypeID IN (0,1)
                BEGIN
                    -- if sowing >= 16 Sep or unknown => 1 Sep - 15 Jan
                    -- else (sowing <= 15 Sep) also mapped to 1 Sep - 15 Jan
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 15);
                END
                ELSE
                BEGIN
                    -- other soils -> 1 Sep - 15 Jan
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 15);
                END
            END
        END
    END

    --------------------------------------------------------------------
    -- 14) IS APPLICATION INSIDE CLOSED PERIOD?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd
        SET @IsApplicationInsideClosedPeriod = 1;
    ELSE
        SET @IsApplicationInsideClosedPeriod = 0;

    --------------------------------------------------------------------
    -- 15) SUM TOTAL N for all FERTILISER records in same ManagementPeriod inside period
    --      TotalFertiliserN = SUM(N * ApplicationRate)
    --------------------------------------------------------------------
    SELECT
        @TotalFertiliserN = SUM(fm.N * ISNULL(fm.ApplicationRate, 1))
    FROM FertiliserManures fm
    WHERE fm.ManagementPeriodID = @ManagementPeriodID
      AND fm.ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd;

    IF @TotalFertiliserN IS NULL SET @TotalFertiliserN = 0;

    --------------------------------------------------------------------
    -- 16) EXCEEDS LIMIT?
    --------------------------------------------------------------------
    IF @TotalFertiliserN > @MaxNitrogenRate
        SET @IsTotalNAboveLimit = 1;
    ELSE
        SET @IsTotalNAboveLimit = 0;

    --------------------------------------------------------------------
    -- 17) FINAL OUTPUT
    --------------------------------------------------------------------
    SELECT
        @FertiliserID AS FertiliserID,
        @FieldID AS FieldID,
        @CropID AS CropID,
        @CropTypeID AS CropTypeID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNVZ AS IsWithinNVZ,

        @IsAllowedCropType AS IsAllowedCropType,
        @IsApplicationInsideClosedPeriod AS IsApplicationInsideClosedPeriod,

        @ClosedPeriodStart AS ClosedPeriodStartDate,
        @ClosedPeriodEnd   AS ClosedPeriodEndDate,

        @TotalFertiliserN AS TotalFertiliserN,
        @MaxNitrogenRate AS MaxNitrogenRate,
        @IsTotalNAboveLimit AS IsTotalNAboveLimit;
END;