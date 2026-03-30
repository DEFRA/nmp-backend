
CREATE PROCEDURE [dbo].[spWarning_CheckScotlandHighRANJulyRestriction]
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
        @CropTypeID INT,

        -- Flags
        @IsFieldScotland BIT = 0,
        @IsHighRanManures BIT = 0,
        @IsJulyPeriod BIT = 0,
        @IsNotGrass BIT = 0,

        @IsTriggered BIT = 0;

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
        @CropTypeID = c.CropTypeID
    FROM Crops c
    WHERE c.ID = @CropID;

    SELECT
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

    IF @ManureTypeID IN (8,12,13,14,15,18,45,46,49,51,52)
        SET @IsHighRanManures = 1;

    -- July check (01–31 July)
    IF MONTH(@ApplicationDate) = 7
        SET @IsJulyPeriod = 1;

    -- Not grass
    IF @CropTypeID <> 140
        SET @IsNotGrass = 1;

    --------------------------------------------------------------------
    -- 3) Final Logic
    --------------------------------------------------------------------
    IF @IsFieldScotland = 1
       AND @IsWithinNVZ = 1
       AND @IsHighRanManures = 1
       AND @IsJulyPeriod = 1
       AND @IsNotGrass = 1
    BEGIN
        SET @IsTriggered = 1;
    END

    --------------------------------------------------------------------
    -- 4) OUTPUT (DEBUG)
    --------------------------------------------------------------------
    SELECT
        @IsTriggered AS IsTriggered,

        -- Flags
        @IsFieldScotland AS IsFieldScotland,
        @IsWithinNVZ AS IsWithinNVZ,
        @IsHighRanManures AS IsHighRanManures,
        @IsJulyPeriod AS IsJulyPeriod,
        @IsNotGrass AS IsNotGrass,

        -- Values
        @ApplicationDate AS ApplicationDate,
        @ManureTypeID AS ManureTypeID,
        @CropTypeID AS CropTypeID;

END