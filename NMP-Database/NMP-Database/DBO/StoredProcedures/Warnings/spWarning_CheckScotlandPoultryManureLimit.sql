
CREATE PROCEDURE [dbo].[spWarning_CheckScotlandPoultryManureLimit]
    @OrganicManureID INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES
    --------------------------------------------------------------------
    DECLARE
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @IsWithinNVZ BIT = 0,
        @ApplicationDate DATE,
        @ManureTypeID INT,
        @CropID INT,
        @CropYear INT,
        @SoilTypeID INT,
        @FieldType INT,
        @CropTypeID INT,
        @SowingDate DATE,

        @ClosedPeriod NVARCHAR(100),
        @ClosedStartDate DATE,
        @ClosedEndDate DATE,

        -- Windows
        @PreWindowStart DATE,
        @PreWindowEnd DATE,
        @PostWindowStart DATE,
        @PostWindowEnd DATE,

        -- NEW
        @TotalApplicationRate DECIMAL(18,3) = 0,

        -- Flags
        @IsFieldScotland BIT = 0,
        @IsPoultryManure BIT = 0,
        @IsWithinPreWindow BIT = 0,
        @IsWithinPostWindow BIT = 0,
        @IsTotalApplicationRateAbove5 BIT = 0,

        @IsTriggered BIT = 0;

    DECLARE @ClosedPeriodTable TABLE (ClosedPeriod NVARCHAR(100));

    DECLARE @ClosedPeriodDates TABLE (
        ClosedPeriod NVARCHAR(100),
        ClosedStartDate DATE,
        ClosedEndDate DATE
    );

    --------------------------------------------------------------------
    -- 1) Load base data
    --------------------------------------------------------------------
    SELECT
        @ApplicationDate = om.ApplicationDate,
        @ManureTypeID = om.ManureTypeID,
        @CropID = mp.CropID
    FROM OrganicManures om
    JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    WHERE om.ID = @OrganicManureID;

    SELECT
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @CropYear = c.Year,
        @SowingDate = c.SowingDate,
        @FieldType = c.FieldType
    FROM Crops c
    WHERE c.ID = @CropID;

    SELECT
        @SoilTypeID = f.SoilTypeID,
        @IsWithinNVZ = ISNULL(f.IsWithinNVZ,0),
        @FarmID = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;

    SELECT
        @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    --------------------------------------------------------------------
    -- 2) Flags
    --------------------------------------------------------------------
    SET @IsFieldScotland = CASE WHEN @CountryID = 2 THEN 1 ELSE 0 END;
    SET @IsPoultryManure = CASE WHEN @ManureTypeID = 8 THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 3) Get Closed Period
    --------------------------------------------------------------------
    INSERT INTO @ClosedPeriodTable
    EXEC dbo.spWarning_GetOrganicManureClosedPeriod
        @SoilTypeID = @SoilTypeID,
        @FieldType = @FieldType,
        @HarvestYear = @CropYear,
        @SowingDate = @SowingDate,
        @CountryId = @CountryID,
        @CropGroupId = NULL,
        @CropTypeId = @CropTypeID,
        @IsPerennial = 0;

    SELECT @ClosedPeriod = ClosedPeriod FROM @ClosedPeriodTable;

    INSERT INTO @ClosedPeriodDates
    EXEC dbo.spConvertClosedPeriodTextToDates
        @ClosedPeriodText = @ClosedPeriod,
        @HarvestYear = @CropYear;

    SELECT
        @ClosedStartDate = ClosedStartDate,
        @ClosedEndDate = ClosedEndDate
    FROM @ClosedPeriodDates;

    --------------------------------------------------------------------
    -- 4) Define Windows
    --------------------------------------------------------------------
    SET @PreWindowStart = DATEADD(DAY, -28, @ClosedStartDate);
    SET @PreWindowEnd   = DATEADD(DAY, -1, @ClosedStartDate);

    DECLARE @FebYear INT;

    IF MONTH(@ClosedEndDate) > 2
        SET @FebYear = @CropYear + 1;
    ELSE
        SET @FebYear = @CropYear;

    SET @PostWindowStart = @ClosedEndDate;
    SET @PostWindowEnd   = DATEFROMPARTS(@FebYear, 2, 14);

    --------------------------------------------------------------------
    -- 5) Check Application Window
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @PreWindowStart AND @PreWindowEnd
        SET @IsWithinPreWindow = 1;

    IF @ApplicationDate BETWEEN @PostWindowStart AND @PostWindowEnd
        SET @IsWithinPostWindow = 1;

    --------------------------------------------------------------------
    -- 6) NEW: SUM(ApplicationRate) > 5 (Poultry only)
    --------------------------------------------------------------------
    SELECT
        @TotalApplicationRate = ISNULL(SUM(om.ApplicationRate), 0)
    FROM OrganicManures om
    JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    JOIN Crops c ON mp.CropID = c.ID
    WHERE 
        c.FieldID = @FieldID
        AND (
            om.ApplicationDate BETWEEN @PreWindowStart AND @PreWindowEnd
            OR
            om.ApplicationDate BETWEEN @PostWindowStart AND @PostWindowEnd
        )
        AND om.ManureTypeID = 8;

    IF @TotalApplicationRate > 5
        SET @IsTotalApplicationRateAbove5 = 1;

    --------------------------------------------------------------------
    -- 7) Final Trigger Logic
    --------------------------------------------------------------------
    IF @IsFieldScotland = 1
       AND @IsWithinNVZ = 1
       AND @IsPoultryManure = 1
       AND (
            @IsWithinPreWindow = 1
            OR @IsWithinPostWindow = 1
       )
       AND @IsTotalApplicationRateAbove5 = 1
    BEGIN
        SET @IsTriggered = 1;
    END

    --------------------------------------------------------------------
    -- 8) OUTPUT (DEBUG)
    --------------------------------------------------------------------
    SELECT
        @IsTriggered AS IsTriggered,

        -- Flags
        @IsFieldScotland AS IsFieldScotland,
        @IsWithinNVZ AS IsWithinNVZ,
        @IsPoultryManure AS IsPoultryManure,
        @IsWithinPreWindow AS IsWithinPreWindow,
        @IsWithinPostWindow AS IsWithinPostWindow,
        @IsTotalApplicationRateAbove5 AS IsTotalApplicationRateAbove5,

        -- Values
        @TotalApplicationRate AS TotalApplicationRate,
        @ApplicationDate AS ApplicationDate,
        @ClosedPeriod AS ClosedPeriod,
        @ClosedStartDate AS ClosedStartDate,
        @ClosedEndDate AS ClosedEndDate,
        @PreWindowStart AS PreWindowStart,
        @PreWindowEnd AS PreWindowEnd,
        @PostWindowStart AS PostWindowStart,
        @PostWindowEnd AS PostWindowEnd;

END