

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
        @SowingDate DATE,
        @ApplicationDate DATE,
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

        -- Date helpers
        @ApplicationMonthDay INT,
        @SowingMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @FebruaryEnd DATE,
        @FebruaryYear INT,

        -- Totals
        @TotalClosedPeriodNitrogen DECIMAL(18,3) = 0,

        -- Perennial
        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0;

    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = CAST(om.ApplicationDate AS DATE),
        @ManureTypeId = om.ManureTypeID,
        @Nitrogen = om.N,
        @ApplicationRate = ISNULL(om.ApplicationRate,0)
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;

    --------------------------------------------------------------------
    -- 2) Crop
    --------------------------------------------------------------------
    SELECT @CropId = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodId;

    SELECT
        @FieldId = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @CropYear = c.Year,
        @SowingDate = CAST(c.SowingDate AS DATE)
    FROM Crops c
    WHERE c.ID = @CropId;

    --------------------------------------------------------------------
    -- 3) Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = ISNULL(f.IsWithinNVZ,0),
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;

    --------------------------------------------------------------------
    -- 4) Farm
    --------------------------------------------------------------------
    SELECT
        @CountryId = fm.CountryID,
        @IsRegisteredOrganicProducer = ISNULL(fm.RegisteredOrganicProducer,0)
    FROM Farms fm
    WHERE fm.ID = @FarmId;

    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;

    --------------------------------------------------------------------
    -- 5) High RAN
    --------------------------------------------------------------------
    IF @ManureTypeId IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;

    --------------------------------------------------------------------
    -- 6) Date helpers
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @SowingMonthDay =
        CASE WHEN @SowingDate IS NULL THEN NULL
             ELSE MONTH(@SowingDate)*100 + DAY(@SowingDate) END;

    --------------------------------------------------------------------
    -- 7) Perennial flags
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = ISNULL(ctl.IsPerennial,0)
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeId;

    IF EXISTS (
        SELECT 1 FROM Crops cprev
        WHERE cprev.FieldID = @FieldId
          AND cprev.Year < @CropYear
    )
        SET @HasPriorYearPlantings = 1;

    --------------------------------------------------------------------
    -- 8) Year Cycle (Aug → Jul)
    --------------------------------------------------------------------
    SET @ApplicationYear = YEAR(@ApplicationDate);

    IF @ApplicationMonthDay < 801
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@ApplicationYear-1,8,1);
        SET @YearCycleEnd   = DATEFROMPARTS(@ApplicationYear,7,31);
    END
    ELSE
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@ApplicationYear,8,1);
        SET @YearCycleEnd   = DATEFROMPARTS(@ApplicationYear+1,7,31);
    END;

    --------------------------------------------------------------------
    -- 9) CLOSED PERIOD LOGIC (UNCHANGED)
    --------------------------------------------------------------------
    IF @CropTypeId = 140
    BEGIN
        IF @SoilTypeId IN (0,1)
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
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
        IF @SoilTypeId IN (0,1)
        BEGIN
            IF @SowingMonthDay IS NULL OR @SowingMonthDay >= 916
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
            ELSE
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);

            SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
        ELSE
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
        END

        IF @IsPerennial = 1 AND @HasPriorYearPlantings = 1
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
    END;

    --------------------------------------------------------------------
    -- 10) FEBRUARY YEAR LOGIC (UPDATED)
    --------------------------------------------------------------------
    IF MONTH(@ClosedPeriodEnd) = 12
        SET @FebruaryYear = YEAR(@ClosedPeriodEnd) + 1;
    ELSE
        SET @FebruaryYear = YEAR(@ClosedPeriodEnd);

    IF ( @FebruaryYear % 400 = 0 )
       OR ( @FebruaryYear % 4 = 0 AND @FebruaryYear % 100 <> 0 )
        SET @FebruaryEnd = DATEFROMPARTS(@FebruaryYear,2,29);
    ELSE
        SET @FebruaryEnd = DATEFROMPARTS(@FebruaryYear,2,28);

    --------------------------------------------------------------------
    -- 11) Inside Closed Period → February
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd
        SET @IsInsideClosedPeriodToFebruary = 1;

    --------------------------------------------------------------------
    -- 12) CropType Allowed
    --------------------------------------------------------------------
    IF @CropTypeId IN (43,41,189,44,194,195,61,62,63,64,70,78,92,93)
        SET @IsCropTypeAllowed = 1;

    --------------------------------------------------------------------
    -- 13) Current N > 50
    --------------------------------------------------------------------
    IF (@Nitrogen * @ApplicationRate) > 50
        SET @IsCurrentNitrogenAboveFifty = 1;

    --------------------------------------------------------------------
    -- 14) TOTAL CLOSED PERIOD N
    --------------------------------------------------------------------
    SELECT
        @TotalClosedPeriodNitrogen =
            ISNULL(SUM(om2.N * om2.ApplicationRate),0)
    FROM OrganicManures om2
    WHERE om2.ManagementPeriodID = @ManagementPeriodId
      AND om2.ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd;

    IF @TotalClosedPeriodNitrogen > 150
        SET @IsTotalClosedPeriodNitrogenAboveOneHundredFifty = 1;

    --------------------------------------------------------------------
    -- 15) Previous application within 28 days
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM OrganicManures om3
        WHERE om3.ManagementPeriodID = @ManagementPeriodId
          AND om3.ID <> @OrganicManureId
          AND om3.ApplicationDate BETWEEN DATEADD(DAY,-27,@ApplicationDate)
                                      AND @ApplicationDate
          AND om3.ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd
    )
        SET @IsPreviousApplicationWithinTwentyEightDays = 1;

    --------------------------------------------------------------------
    -- 16) FINAL OUTPUT
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

        (@Nitrogen * @ApplicationRate) AS CurrentNitrogen;
END;