
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

        -- Harvest year logic (now using Year)
        @Year INT,
        @NextYear INT,
        @NextEarliestSowingDate DATE,
        @HasValidGap BIT = 0,

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
        @CropTypeID = c.CropTypeID,
        @Year = c.Year
    FROM Crops c
    WHERE c.ID = @CropID;

    SELECT
        @IsWithinNVZ = ISNULL(f.IsWithinNVZ, 0),
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

    IF MONTH(@ApplicationDate) = 7
        SET @IsJulyPeriod = 1;

    IF @CropTypeID <> 140
        SET @IsNotGrass = 1;

    --------------------------------------------------------------------
    -- 3) FUTURE CROP PLANNING (using Year)
    --------------------------------------------------------------------
    IF @Year IS NOT NULL
    BEGIN
        SET @NextYear = @Year + 1;

        SELECT 
            @NextEarliestSowingDate = MIN(c.SowingDate)
        FROM Crops c
        WHERE 
            c.FieldID = @FieldID
            AND c.Year = @NextYear;

        IF @NextEarliestSowingDate IS NULL
            OR DATEDIFF(DAY, @ApplicationDate, @NextEarliestSowingDate) >= 43
        BEGIN
            SET @HasValidGap = 1;
        END
    END

    --------------------------------------------------------------------
    -- 4) Final Logic
    --------------------------------------------------------------------
    IF @IsFieldScotland = 1
       AND @IsWithinNVZ = 1
       AND @IsHighRanManures = 1
       AND @IsJulyPeriod = 1
       AND @IsNotGrass = 1
       AND @HasValidGap = 0
    BEGIN
        SET @IsTriggered = 1;
    END

    --------------------------------------------------------------------
    -- 5) OUTPUT
    --------------------------------------------------------------------
    SELECT
        @IsTriggered AS IsTriggered,
        @IsFieldScotland AS IsFieldScotland,
        @IsWithinNVZ AS IsWithinNVZ,
        @IsHighRanManures AS IsHighRanManures,
        @IsJulyPeriod AS IsJulyPeriod,
        @IsNotGrass AS IsNotGrass,
        @HasValidGap AS HasValidGap,
        @ApplicationDate AS ApplicationDate,
        @ManureTypeID AS ManureTypeID,
        @CropTypeID AS CropTypeID,
        @Year AS CurrentYear,
        @NextYear AS NextYear,
        @NextEarliestSowingDate AS NextEarliestSowingDate;

END