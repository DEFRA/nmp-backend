

CREATE PROCEDURE [dbo].[spWarning_CheckScotlandNFertiliserClosedPeriod]
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
        @NvzID INT,
        @HarvestYear INT,

        @ClosedPeriod NVARCHAR(100),
        @ClosedStartDate DATE,
        @ClosedEndDate DATE,

        -- Flags
        @IsFieldScotland BIT = 0,
        @IsCropExcluded BIT = 0,
        @IsWithinClosedPeriod BIT = 0,

        @IsTriggered BIT = 0;

    DECLARE @ClosedPeriodTable TABLE (ClosedPeriod NVARCHAR(100));

    DECLARE @ClosedPeriodDates TABLE (
        ClosedPeriod NVARCHAR(100),
        ClosedStartDate DATE,
        ClosedEndDate DATE
    );

    --------------------------------------------------------------------
    -- 1) Load Fertiliser Data
    --------------------------------------------------------------------
    SELECT
        @ApplicationDate = f.ApplicationDate,
        @CropID = mp.CropID
    FROM FertiliserManures f
    JOIN ManagementPeriods mp ON f.ManagementPeriodID = mp.ID
    WHERE f.ID = @FertiliserID;

    -- Fix: assign HarvestYear properly
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

    IF @CropTypeID IN (43, 41, 189, 194, 195, 61, 62, 63, 64, 70, 78, 93, 182, 188)
        SET @IsCropExcluded = 1;

    --------------------------------------------------------------------
    -- 3) Get Fertiliser Closed Period
    --------------------------------------------------------------------
    INSERT INTO @ClosedPeriodTable
    EXEC dbo.spWarning_GetFertiliserManureClosedPeriod
        @CountryId = @CountryID,
        @CropTypeId = @CropTypeID,
        @NvzId = @NvzID;

    SELECT @ClosedPeriod = ClosedPeriod FROM @ClosedPeriodTable;

    --------------------------------------------------------------------
    -- Convert Closed Period to Dates
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
    -- 4) Check Closed Period
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
        SET @IsWithinClosedPeriod = 1;

    --------------------------------------------------------------------
    -- 5) Final Logic
    --------------------------------------------------------------------
    IF @IsFieldScotland = 1
       AND @IsWithinNVZ = 1
       AND @IsWithinClosedPeriod = 1
       AND @IsCropExcluded = 0
    BEGIN
        SET @IsTriggered = 1;
    END

    --------------------------------------------------------------------
    -- 6) OUTPUT (DEBUG)
    --------------------------------------------------------------------
    SELECT
        @IsTriggered AS IsTriggered,

        -- Flags
        @IsFieldScotland AS IsFieldScotland,
        @IsWithinNVZ AS IsWithinNVZ,
        @IsWithinClosedPeriod AS IsWithinClosedPeriod,
        @IsCropExcluded AS IsCropExcluded,

        -- Values
        @ApplicationDate AS ApplicationDate,
        @CropTypeID AS CropTypeID,
        @NvzID AS NvzID,
        @ClosedPeriod AS ClosedPeriod,
        @ClosedStartDate AS ClosedStartDate,
        @ClosedEndDate AS ClosedEndDate;

END