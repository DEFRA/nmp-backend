
CREATE PROCEDURE [dbo].[spWarning_CheckScotlandLivestock20DayGap]
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

        @PreviousApplicationDate DATE,
        @DaysDifference INT,

        -- Flags
        @IsFieldScotland BIT = 0,
        @IsLivestockManure BIT = 0,
        @IsWithin20Days BIT = 0,

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
        @FieldID = c.FieldID
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

    IF @ManureTypeID IN (0,1,2,3,4,5,6,7,8,30,41,45,12,13,14,15,16,18,17,19)
        SET @IsLivestockManure = 1;

    --------------------------------------------------------------------
    -- 3) Get Previous Livestock Application (same field)
    --------------------------------------------------------------------
    SELECT TOP 1
        @PreviousApplicationDate = om.ApplicationDate
    FROM OrganicManures om
    JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    JOIN Crops c ON mp.CropID = c.ID
    WHERE c.FieldID = @FieldID
      AND om.ApplicationDate < @ApplicationDate
      AND om.ManureTypeID IN (0,1,2,3,4,5,6,7,8,30,41,45,12,13,14,15,16,18,17,19)
    ORDER BY om.ApplicationDate DESC;

    --------------------------------------------------------------------
    -- 4) Calculate Difference
    --------------------------------------------------------------------
    IF @PreviousApplicationDate IS NOT NULL
    BEGIN
        SET @DaysDifference = DATEDIFF(DAY, @PreviousApplicationDate, @ApplicationDate);

        IF @DaysDifference <= 20
            SET @IsWithin20Days = 1;
    END

    --------------------------------------------------------------------
    -- 5) Final Trigger Logic
    --------------------------------------------------------------------
    IF @IsFieldScotland = 1
       AND @IsWithinNVZ = 1
       AND @IsLivestockManure = 1
       AND @IsWithin20Days = 1
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
        @IsLivestockManure AS IsLivestockManure,
        @IsWithin20Days AS IsWithin20Days,

        -- Values
        @ApplicationDate AS CurrentApplicationDate,
        @PreviousApplicationDate AS PreviousApplicationDate,
        @DaysDifference AS DaysDifference;

END