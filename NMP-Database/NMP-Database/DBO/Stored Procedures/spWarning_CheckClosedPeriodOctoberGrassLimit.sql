

CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodOctoberGrassLimit]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES
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
        @N DECIMAL(18,3),
        @ApplicationRate DECIMAL(18,3),

        -- Flags
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNvz BIT = 0,
        @IsRegisteredOrganicProducer BIT = 0,
        @IsHighRanManures BIT = 0,
        @IsGrassCropType BIT = 0,
        @IsInsideClosedPeriodToOctober BIT = 0,
        @IsTotalClosedPeriodNitrogenAboveOneHundredFifty BIT = 0,
        @IsAnyOrganicManureAboveForty BIT = 0,

        -- Dates
        @ApplicationMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @OctoberEnd DATE,

        -- Total N
        @TotalClosedPeriodNitrogen DECIMAL(18,3) = 0;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure (INCLUDES ApplicationRate)
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = om.ApplicationDate,
        @ManureTypeId = om.ManureTypeID,
        @N = om.N,
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
    -- 4) Grass flag
    --------------------------------------------------------------------
    IF @CropTypeId = 140 SET @IsGrassCropType = 1;


    --------------------------------------------------------------------
    -- 5) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------------------
    -- 6) Load Farm
    --------------------------------------------------------------------
    SELECT
        @CountryId = fm.CountryID,
        @IsRegisteredOrganicProducer =
            CASE WHEN ISNULL(fm.RegisteredOrganicProducer,0)=1 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmId;


    --------------------------------------------------------------------
    -- 7) Country flags
    --------------------------------------------------------------------
    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------------------
    -- 8) High RAN Manures
    --------------------------------------------------------------------
    IF @ManureTypeId IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;


    --------------------------------------------------------------------
    -- 9) Date helpers
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @ApplicationYear = YEAR(@ApplicationDate);


    --------------------------------------------------------------------
    -- 10) Year cycle August → July
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
    -- 11) Closed period start/end (Grass rules)
    --------------------------------------------------------------------
    IF @SoilTypeId IN (0,1)
    BEGIN
        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
    END
    ELSE
    BEGIN
        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,15);
        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
    END;


    --------------------------------------------------------------------
    -- 12) October end
    --------------------------------------------------------------------
    SET @OctoberEnd = DATEFROMPARTS(YEAR(@ClosedPeriodStart),10,31);


    --------------------------------------------------------------------
    -- 13) Inside Closed → October?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @OctoberEnd
        SET @IsInsideClosedPeriodToOctober = 1;


    --------------------------------------------------------------------
    -- 14) SUM Total N = N * ApplicationRate
    --------------------------------------------------------------------
    SELECT
        @TotalClosedPeriodNitrogen =
            SUM(om2.N * om2.ApplicationRate)
    FROM OrganicManures om2
    WHERE om2.ManagementPeriodID = @ManagementPeriodId
      AND om2.ApplicationDate BETWEEN @ClosedPeriodStart AND @OctoberEnd;

    IF @TotalClosedPeriodNitrogen IS NULL
        SET @TotalClosedPeriodNitrogen = 0;


    --------------------------------------------------------------------
    -- 15) TotalN > 150
    --------------------------------------------------------------------
    IF @TotalClosedPeriodNitrogen > 150
        SET @IsTotalClosedPeriodNitrogenAboveOneHundredFifty = 1;


    --------------------------------------------------------------------
    -- 16) ANY OM > 40 (using N * ApplicationRate)
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsAnyOrganicManureAboveForty = 1
    FROM OrganicManures om3
    WHERE om3.ManagementPeriodID = @ManagementPeriodId
      AND om3.ApplicationDate BETWEEN @ClosedPeriodStart AND @OctoberEnd
      AND (om3.N * om3.ApplicationRate) > 40;


    --------------------------------------------------------------------
    -- 17) RETURN VALUES
    --------------------------------------------------------------------
    SELECT
        @OrganicManureId AS OrganicManureId,
        @CropId AS CropId,
        @CropTypeId AS CropTypeId,
        @IsGrassCropType AS IsGrassCropType,

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

        @IsAnyOrganicManureAboveForty AS IsAnyOrganicManureAboveForty,

        (@N * @ApplicationRate) AS CurrentNitrogen;

END;