
CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodOctoberWinterOilSeedRapeLimit]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES (alphabet-only)
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
        @IsWinterOilSeedRapeCropType BIT = 0,
        @IsInsideClosedPeriodToOctober BIT = 0,
        @IsTotalClosedPeriodNitrogenAboveOneHundredFifty BIT = 0,

        -- Date helpers
        @ApplicationMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @OctoberEnd DATE,

        -- Totals
        @TotalClosedPeriodNitrogen DECIMAL(18,3) = 0,

        -- Perennial flags
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
    -- 2) Get CropId from ManagementPeriod
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
    -- ⭐ NEW: 4) Fetch IsPerennial from CropTypeLinkings ⭐
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0) = 1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeId;


    --------------------------------------------------------------------
    -- 5) WOSR check (Crop Type 20)
    --------------------------------------------------------------------
    IF @CropTypeId = 20
        SET @IsWinterOilSeedRapeCropType = 1;
    ELSE
        SET @IsWinterOilSeedRapeCropType = 0;


    --------------------------------------------------------------------
    -- 6) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------------------
    -- 7) Load Farm
    --------------------------------------------------------------------
    SELECT
        @CountryId = fm.CountryID,
        @IsRegisteredOrganicProducer =
            CASE WHEN ISNULL(fm.RegisteredOrganicProducer,0)=1 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmId;


    --------------------------------------------------------------------
    -- 8) Country flags
    --------------------------------------------------------------------
    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------------------
    -- 9) High RAN Manures
    --------------------------------------------------------------------
    IF @ManureTypeId IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;
    ELSE
        SET @IsHighRanManures = 0;


    --------------------------------------------------------------------
    -- 10) Date helpers
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @ApplicationYear = YEAR(@ApplicationDate);


    --------------------------------------------------------------------
    -- 11) Year cycle (Aug 1 → Jul 31)
    --------------------------------------------------------------------
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
    -- 12) Closed Period Logic (UPDATED with IsPerennial)
    --------------------------------------------------------------------
    IF @IsPerennial = 0
    BEGIN
        IF @SoilTypeId IN (0,1)
        BEGIN
            IF @SowingDate IS NULL
                OR (MONTH(@SowingDate)*100 + DAY(@SowingDate)) >= 916
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
    END
    ELSE
    BEGIN
        IF @SoilTypeId IN (0,1)
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
        ELSE
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
        END
    END;


    --------------------------------------------------------------------
    -- 13) October End Date
    --------------------------------------------------------------------
    SET @OctoberEnd = DATEFROMPARTS(YEAR(@ClosedPeriodStart),10,31);


    --------------------------------------------------------------------
    -- 14) Inside closed period up to October 31?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @OctoberEnd
        SET @IsInsideClosedPeriodToOctober = 1;
    ELSE
        SET @IsInsideClosedPeriodToOctober = 0;


    --------------------------------------------------------------------
    -- 15) Total N inside closed period → Oct 31
    --------------------------------------------------------------------
    SELECT
        @TotalClosedPeriodNitrogen = SUM(om2.N * om2.ApplicationRate)
    FROM OrganicManures om2
    WHERE om2.ManagementPeriodID = @ManagementPeriodId
      AND om2.ApplicationDate BETWEEN @ClosedPeriodStart AND @OctoberEnd;

    IF @TotalClosedPeriodNitrogen IS NULL
        SET @TotalClosedPeriodNitrogen = 0;


    --------------------------------------------------------------------
    -- 16) Total N > 150?
    --------------------------------------------------------------------
    IF @TotalClosedPeriodNitrogen > 150
        SET @IsTotalClosedPeriodNitrogenAboveOneHundredFifty = 1;
    ELSE
        SET @IsTotalClosedPeriodNitrogenAboveOneHundredFifty = 0;


    --------------------------------------------------------------------
    -- 17) Final Output
    --------------------------------------------------------------------
    SELECT
        @OrganicManureId AS OrganicManureId,
        @CropId AS CropId,
        @CropTypeId AS CropTypeId,
        @IsWinterOilSeedRapeCropType AS IsWinterOilSeedRapeCropType,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNvz AS IsWithinNvz,
        @IsRegisteredOrganicProducer AS IsRegisteredOrganicProducer,
        @IsHighRanManures AS IsHighRanManures,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,
        @OctoberEnd AS OctoberEnd,
        @IsInsideClosedPeriodToOctober AS IsInsideClosedPeriodToOctober,

        @TotalClosedPeriodNitrogen AS TotalClosedPeriodNitrogen,
        @IsTotalClosedPeriodNitrogenAboveOneHundredFifty AS IsTotalClosedPeriodNitrogenAboveOneHundredFifty,

        @Nitrogen AS CurrentNitrogen;

END;