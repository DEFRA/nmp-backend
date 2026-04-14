
CREATE PROCEDURE [dbo].[spWarning_CheckScotlandFertiliserNResidueGroupSpecific]
    @FertiliserID INT
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
        @CropID INT,
        @CropTypeID INT,
        @ManagementPeriodID INT,
        @HarvestYear INT,
        @NvzID INT,

        @ClosedPeriod NVARCHAR(100),
        @ClosedStartDate DATE,
        @ClosedEndDate DATE,

        -- Flags
        @IsFieldScotland BIT = 0,
        @IsWinterOSR BIT = 0,
        @IsWithinClosedPeriod BIT = 0,
        @IsNResidueGroup456 BIT = 0,

        @NIndex INT,
        @IsTriggered BIT = 0;

    --------------------------------------------------------------------
    -- Temp Tables
    --------------------------------------------------------------------
    DECLARE @ClosedPeriodTable TABLE (ClosedPeriod NVARCHAR(100));

    DECLARE @ClosedPeriodDates TABLE (
        ClosedPeriod NVARCHAR(100),
        ClosedStartDate DATE,
        ClosedEndDate DATE
    );

    --------------------------------------------------------------------
    -- 1) Load Fertiliser + Context
    --------------------------------------------------------------------
    SELECT
        @ApplicationDate = f.ApplicationDate,
        @ManagementPeriodID = f.ManagementPeriodID,
        @CropID = mp.CropID
    FROM FertiliserManures f
    INNER JOIN ManagementPeriods mp ON f.ManagementPeriodID = mp.ID
    WHERE f.ID = @FertiliserID;

    SET @HarvestYear = YEAR(@ApplicationDate);

    SELECT
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID
    FROM Crops c
    WHERE c.ID = @CropID;

    SELECT
        @IsWithinNVZ = ISNULL(fld.IsWithinNVZ,0),
        @FarmID = fld.FarmID,
        @NvzID = fld.NVZProgrammeID
    FROM Fields fld
    WHERE fld.ID = @FieldID;

    SELECT
        @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    --------------------------------------------------------------------
    -- 2) Flags
    --------------------------------------------------------------------
    SET @IsFieldScotland = CASE WHEN @CountryID = 2 THEN 1 ELSE 0 END;
    SET @IsWinterOSR = CASE WHEN @CropTypeID = 20 THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 3) Get NIndex
    --------------------------------------------------------------------
    SELECT TOP 1
        @NIndex = r.NIndex
    FROM Recommendations r
    WHERE r.ManagementPeriodID = @ManagementPeriodID;

    IF @NIndex IN (4,5,6)
        SET @IsNResidueGroup456 = 1;

    --------------------------------------------------------------------
    -- 4) Get Closed Period
    --------------------------------------------------------------------
    INSERT INTO @ClosedPeriodTable
    EXEC dbo.spWarning_GetFertiliserManureClosedPeriod
        @CountryId = @CountryID,
        @CropTypeId = @CropTypeID,
        @NvzId = @NvzID;

    SELECT @ClosedPeriod = ClosedPeriod FROM @ClosedPeriodTable;

    --------------------------------------------------------------------
    -- Convert Closed Period → Dates
    --------------------------------------------------------------------
    INSERT INTO @ClosedPeriodDates
    EXEC dbo.spConvertClosedPeriodTextToDates
        @ClosedPeriodText = @ClosedPeriod,
        @HarvestYear = @HarvestYear;

    SELECT
        @ClosedStartDate = ClosedStartDate,
        @ClosedEndDate = ClosedEndDate
    FROM @ClosedPeriodDates;

    --------------------------------------------------------------------
    -- 5) Check Application within Closed Period
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
        SET @IsWithinClosedPeriod = 1;

    --------------------------------------------------------------------
    -- 6) Final Trigger Logic
    --------------------------------------------------------------------
    IF @IsFieldScotland = 1
       AND @IsWithinNVZ = 1
       AND @IsWinterOSR = 1
       AND @IsWithinClosedPeriod = 1
       AND @IsNResidueGroup456 = 1
    BEGIN
        SET @IsTriggered = 1;
    END

    --------------------------------------------------------------------
    -- 7) OUTPUT (DEBUG FRIENDLY)
    --------------------------------------------------------------------
    SELECT
        @IsTriggered AS IsTriggered,

        -- Rule info
        @NIndex AS NIndex,
        @IsNResidueGroup456 AS IsNResidueGroup456,

        -- Flags
        @IsFieldScotland AS IsFieldScotland,
        @IsWithinNVZ AS IsWithinNVZ,
        @IsWinterOSR AS IsWinterOSR,
        @IsWithinClosedPeriod AS IsWithinClosedPeriod,

        -- Values
        @ApplicationDate AS ApplicationDate,
        @ClosedPeriod AS ClosedPeriod,
        @ClosedStartDate AS ClosedStartDate,
        @ClosedEndDate AS ClosedEndDate;

END