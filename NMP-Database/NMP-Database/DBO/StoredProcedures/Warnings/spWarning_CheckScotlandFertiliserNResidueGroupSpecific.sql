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
        @IsWithinNVZ BIT,
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
        @IsFieldScotland BIT,
        @IsWinterOSR BIT,
        @IsWithinClosedPeriod BIT = 0,
        @IsNResidueGroup456 BIT = 0,

        @NIndex INT,
        @IsTriggered BIT = 0;

    --------------------------------------------------------------------
    -- 1) LOAD ALL CONTEXT IN SINGLE QUERY (🔥 removes duplication)
    --------------------------------------------------------------------
    SELECT
        @ApplicationDate = f.ApplicationDate,
        @ManagementPeriodID = f.ManagementPeriodID,
        @CropID = mp.CropID,
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @FarmID = fld.FarmID,
        @IsWithinNVZ = ISNULL(fld.IsWithinNVZ,0),
        @NvzID = fld.NVZProgrammeID,
        @CountryID = fm.CountryID
    FROM FertiliserManures f
    INNER JOIN ManagementPeriods mp ON f.ManagementPeriodID = mp.ID
    INNER JOIN Crops c ON mp.CropID = c.ID
    INNER JOIN Fields fld ON c.FieldID = fld.ID
    INNER JOIN Farms fm ON fld.FarmID = fm.ID
    WHERE f.ID = @FertiliserID;

    SET @HarvestYear = YEAR(@ApplicationDate);

    --------------------------------------------------------------------
    -- 2) FLAGS (single place)
    --------------------------------------------------------------------
    SET @IsFieldScotland = CASE WHEN @CountryID = 2 THEN 1 ELSE 0 END;
    SET @IsWinterOSR = CASE WHEN @CropTypeID = 20 THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 3) NIndex
    --------------------------------------------------------------------
    SELECT TOP 1
        @NIndex = r.NIndex
    FROM Recommendations r
    WHERE r.ManagementPeriodID = @ManagementPeriodID;

    SET @IsNResidueGroup456 = CASE WHEN @NIndex IN (4,5,6) THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 4) CLOSED PERIOD (compact version)
    --------------------------------------------------------------------
    DECLARE @ClosedPeriodTable TABLE (ClosedPeriod NVARCHAR(100));

    INSERT INTO @ClosedPeriodTable
    EXEC dbo.spWarning_GetFertiliserManureClosedPeriod
        @CountryId = @CountryID,
        @CropTypeId = @CropTypeID,
        @NvzId = @NvzID;

    SELECT TOP 1 @ClosedPeriod = ClosedPeriod FROM @ClosedPeriodTable;

    --------------------------------------------------------------------
    -- Convert Closed Period → Dates (no extra duplication)
    --------------------------------------------------------------------
    DECLARE @ClosedPeriodDates TABLE (
        ClosedStartDate DATE,
        ClosedEndDate DATE
    );

    INSERT INTO @ClosedPeriodDates
    EXEC dbo.spConvertClosedPeriodTextToDates
        @ClosedPeriodText = @ClosedPeriod,
        @HarvestYear = @HarvestYear;

    SELECT TOP 1
        @ClosedStartDate = ClosedStartDate,
        @ClosedEndDate = ClosedEndDate
    FROM @ClosedPeriodDates;

    --------------------------------------------------------------------
    -- 5) Closed Period Check
    --------------------------------------------------------------------
    SET @IsWithinClosedPeriod =
        CASE 
            WHEN @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate THEN 1 
            ELSE 0 
        END;

    --------------------------------------------------------------------
    -- 6) Final Trigger Logic
    --------------------------------------------------------------------
    SET @IsTriggered =
        CASE 
            WHEN @IsFieldScotland = 1
             AND @IsWithinNVZ = 1
             AND @IsWinterOSR = 1
             AND @IsWithinClosedPeriod = 1
             AND @IsNResidueGroup456 = 1
            THEN 1
            ELSE 0
        END;

    --------------------------------------------------------------------
    -- 7) OUTPUT
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