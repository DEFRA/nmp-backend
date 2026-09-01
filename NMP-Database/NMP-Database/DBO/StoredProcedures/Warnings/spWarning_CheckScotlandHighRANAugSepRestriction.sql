
CREATE PROCEDURE [dbo].[spWarning_CheckScotlandHighRANAugSepRestriction]
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
        @SowingDate DATE,

        -- Flags
        @IsFieldScotland BIT = 0,
        @IsHighRanManures BIT = 0,
        @IsAugSepPeriod BIT = 0,
        @IsNotGrass BIT = 0,
        @IsSowingConditionMet BIT = 0,

        @DaysDiff INT,
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
        @CropTypeID = c.CropTypeID,
        @SowingDate = c.SowingDate
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

    -- Aug → Sep check
    IF MONTH(@ApplicationDate) IN (8,9)
        SET @IsAugSepPeriod = 1;

    -- Not grass
    IF @CropTypeID <> 140
        SET @IsNotGrass = 1;

    --------------------------------------------------------------------
    -- 3) Sowing condition
    --------------------------------------------------------------------
    IF @SowingDate IS NULL
    BEGIN
        SET @IsSowingConditionMet = 1;
    END
    ELSE
    BEGIN
        SET @DaysDiff = DATEDIFF(DAY, @ApplicationDate, @SowingDate);

        IF @DaysDiff >= 43
            SET @IsSowingConditionMet = 1;
    END

    --------------------------------------------------------------------
    -- 4) Final Logic
    --------------------------------------------------------------------
    IF @IsFieldScotland = 1
       AND @IsWithinNVZ = 1
       AND @IsHighRanManures = 1
       AND @IsAugSepPeriod = 1
       AND @IsNotGrass = 1
       AND @IsSowingConditionMet = 1
    BEGIN
        SET @IsTriggered = 1;
    END

    --------------------------------------------------------------------
    -- 5) OUTPUT (DEBUG)
    --------------------------------------------------------------------
    SELECT
        @IsTriggered AS IsTriggered,

        -- Flags
        @IsFieldScotland AS IsFieldScotland,
        @IsWithinNVZ AS IsWithinNVZ,
        @IsHighRanManures AS IsHighRanManures,
        @IsAugSepPeriod AS IsAugSepPeriod,
        @IsNotGrass AS IsNotGrass,
        @IsSowingConditionMet AS IsSowingConditionMet,

        -- Values
        @ApplicationDate AS ApplicationDate,
        @SowingDate AS SowingDate,
        @DaysDiff AS DaysDifference,
        @CropTypeID AS CropTypeID,
        @ManureTypeID AS ManureTypeID;

END