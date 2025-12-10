


CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodTwentyEightDayLimit]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLE DECLARATIONS
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodId INT,
        @CropId INT,
        @FieldId INT,
        @FarmId INT,
        @CountryId INT,
        @CropTypeId INT,
        @CropYear INT,
        @SowingDate DATETIME,
        @ApplicationDate DATETIME,
        @ManureTypeId INT,
        @SoilTypeId INT,
        @Nitrogen DECIMAL(18,3),
        @ApplicationRate DECIMAL(18,3),

        -- Flags
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNvz BIT = 0,
        @IsRegisteredOrganicProducer BIT = 0,
        @IsHighRanManures BIT = 0,
        @IsInsideClosedPeriodToFebruary BIT = 0,
        @IsCropTypeAllowed BIT = 0,
        @IsCurrentNitrogenAboveFifty BIT = 0,
        @IsTotalClosedPeriodNitrogenAboveOneHundredFifty BIT = 0,
        @IsPreviousApplicationWithinTwentyEightDays BIT = 0,

        -- Date Helpers
        @ApplicationMonthDay INT,
        @SowingMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @FebruaryEnd DATE,

        -- Totals
        @TotalClosedPeriodNitrogen DECIMAL(18,3) = 0,

        -- Perennial Logic
        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = om.ApplicationDate,
        @ManureTypeId = om.ManureTypeID,
        @Nitrogen = om.N,
        @ApplicationRate = om.ApplicationRate
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;


    --------------------------------------------------------------------
    -- 2) ManagementPeriod → Crop
    --------------------------------------------------------------------
    SELECT @CropId = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodId;


    --------------------------------------------------------------------
    -- 3) Load Crop
    --------------------------------------------------------------------
    SELECT
        @FieldId = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @CropYear = c.Year,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropId;


    --------------------------------------------------------------------
    -- 4) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------------------
    -- 5) Load Farm
    --------------------------------------------------------------------
    SELECT
        @CountryId = fm.CountryID,
        @IsRegisteredOrganicProducer =
            CASE WHEN ISNULL(fm.RegisteredOrganicProducer,0)=1 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmId;


    --------------------------------------------------------------------
    -- 6) Country Flags
    --------------------------------------------------------------------
    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------------------
    -- 7) High RAN (Readily Available Nitrogen) manures
    --------------------------------------------------------------------
    IF @ManureTypeId IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;


    --------------------------------------------------------------------
    -- 8) Prepare Dates
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate) * 100 + DAY(@ApplicationDate);

    IF @SowingDate IS NOT NULL
         SET @SowingMonthDay = MONTH(@SowingDate) * 100 + DAY(@SowingDate);
    ELSE SET @SowingMonthDay = NULL;


    --------------------------------------------------------------------
    -- 9) Perennial Check
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeId;


    --------------------------------------------------------------------
    -- 10) Prior Year Crop Exists?
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1 FROM Crops cprev
        WHERE cprev.FieldID = @FieldId
          AND cprev.Year < @CropYear
    )
       SET @HasPriorYearPlantings = 1;


    --------------------------------------------------------------------
    -- 11) Year Cycle (1 Aug – 31 July)
    --------------------------------------------------------------------
    SET @ApplicationYear = YEAR(@ApplicationDate);

    IF @ApplicationMonthDay < 801
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@ApplicationYear - 1, 8, 1);
        SET @YearCycleEnd   = DATEFROMPARTS(@ApplicationYear, 7, 31);
    END
    ELSE
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@ApplicationYear, 8, 1);
        SET @YearCycleEnd   = DATEFROMPARTS(@ApplicationYear + 1, 7, 31);
    END;


    --------------------------------------------------------------------
    -- 12) CLOSED PERIOD BLOCK (FULL AS YOU PROVIDED)
    --------------------------------------------------------------------
    SET @ClosedPeriodStart = NULL;
    SET @ClosedPeriodEnd = NULL;

    IF @CropTypeId = 140
    BEGIN
        IF @SoilTypeId IN (11,12)
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
            SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart), 12, 31);
        END
        ELSE
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 10, 15);
            SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 31);
        END
    END
    ELSE
    BEGIN
        IF @IsPerennial = 0
        BEGIN
            IF @SoilTypeId IN (11,12)
            BEGIN
                IF @SowingMonthDay IS NULL OR @SowingMonthDay >= 916
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 8, 1);
                ELSE
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 16);

                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart), 12, 31);
            END
            ELSE
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 10, 1);
                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 31);
            END
        END
        ELSE
        BEGIN
            IF @SoilTypeId IN (11,12)
            BEGIN
                IF @SowingMonthDay IS NULL OR @SowingMonthDay >= 916
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 8, 1);
                ELSE
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 16);

                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart), 12, 31);

                IF @HasPriorYearPlantings = 1
                BEGIN
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 16);
                    SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart), 12, 31);
                END
            END
            ELSE
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart), 10, 1);
                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart) + 1, 1, 31);
            END
        END
    END;


    --------------------------------------------------------------------
    -- 13) End of February (Leap-Year Aware)
    --------------------------------------------------------------------
    IF (YEAR(@ApplicationDate)%4=0 AND YEAR(@ApplicationDate)%100<>0)
        OR (YEAR(@ApplicationDate)%400=0)
        SET @FebruaryEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,29);
    ELSE
        SET @FebruaryEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,28);


    --------------------------------------------------------------------
    -- 14) Inside Closed Period → Feb?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd
        SET @IsInsideClosedPeriodToFebruary = 1;


    --------------------------------------------------------------------
    -- 15) CropType Allowed?
    --------------------------------------------------------------------
    IF @CropTypeId IN (43,41,189,44,194,195,61,62,63,64,70,78,92,93)
        SET @IsCropTypeAllowed = 1;


    --------------------------------------------------------------------
    -- 16) Current Nitrogen > 50  (N * Rate)
    --------------------------------------------------------------------
    IF (@Nitrogen * @ApplicationRate) > 50
        SET @IsCurrentNitrogenAboveFifty = 1;


    --------------------------------------------------------------------
    -- 17) TOTAL N inside Closed Period (N * Rate)
    --------------------------------------------------------------------
    SELECT
        @TotalClosedPeriodNitrogen =
            SUM(om2.N * om2.ApplicationRate)
    FROM OrganicManures om2
    WHERE om2.ManagementPeriodID = @ManagementPeriodId
      AND om2.ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd;

    IF @TotalClosedPeriodNitrogen IS NULL
        SET @TotalClosedPeriodNitrogen = 0;


    --------------------------------------------------------------------
    -- 18) Total N > 150
    --------------------------------------------------------------------
    IF @TotalClosedPeriodNitrogen > 150
        SET @IsTotalClosedPeriodNitrogenAboveOneHundredFifty = 1;


    --------------------------------------------------------------------
    -- 19) Previous OM within 28 days (Inside Closed→Feb)
    --------------------------------------------------------------------
    SELECT TOP 1 @IsPreviousApplicationWithinTwentyEightDays = 1
    FROM OrganicManures om3
    WHERE om3.ManagementPeriodID = @ManagementPeriodId
      AND om3.ID <> @OrganicManureId
      AND om3.ApplicationDate BETWEEN DATEADD(DAY,-28,@ApplicationDate) AND @ApplicationDate
      AND om3.ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd;


    --------------------------------------------------------------------
    -- 20) FINAL OUTPUT
    --------------------------------------------------------------------
    SELECT
        @OrganicManureId AS OrganicManureId,
        @CropId AS CropId,
        @FieldId AS FieldId,
        @FarmId AS FarmId,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNvz AS IsWithinNvz,
        @IsRegisteredOrganicProducer AS IsRegisteredOrganicProducer,
        @IsHighRanManures AS IsHighRanManures,

        @IsInsideClosedPeriodToFebruary AS IsInsideClosedPeriodToFebruary,
        @IsCropTypeAllowed AS IsCropTypeAllowed,
        @IsCurrentNitrogenAboveFifty AS IsCurrentNitrogenAboveFifty,

        @TotalClosedPeriodNitrogen AS TotalClosedPeriodNitrogen,
        @IsTotalClosedPeriodNitrogenAboveOneHundredFifty AS IsTotalClosedPeriodNitrogenAboveOneHundredFifty,
        @IsPreviousApplicationWithinTwentyEightDays AS IsPreviousApplicationWithinTwentyEightDays,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,
        @FebruaryEnd AS FebruaryEnd,

        @Nitrogen AS CurrentNitrogen,
        @ApplicationRate AS ApplicationRate;
END;