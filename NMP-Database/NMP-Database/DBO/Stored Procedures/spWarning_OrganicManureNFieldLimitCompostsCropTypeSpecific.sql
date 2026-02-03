


CREATE PROCEDURE [dbo].[spWarning_OrganicManureNFieldLimitCompostsCropTypeSpecific]
    @OrganicManureID INT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- VARIABLES
    -------------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,
        @ApplicationDate DATETIME,
        @ManureTypeID INT,

        @FourYearsBefore DATETIME,
        @TotalOrganicManureN DECIMAL(18,3),

        @IsFieldWithinNVZ BIT = 0,
        @IsFieldInEngland BIT = 0,
        @IsFieldInWelsh BIT = 0,

        @IsTotalNAbove1000 BIT = 0,   -- ✅ FIXED
        @IsGreenCompost BIT = 0,
        @IsAllowedCrops BIT = 0,
        @CropCount INT;


    -------------------------------------------------------------------------
    -- 1️⃣ LOAD ORGANIC MANURE DETAILS
    -------------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = om.ManagementPeriodID,
        @ApplicationDate    = om.ApplicationDate,
        @ManureTypeID       = om.ManureTypeID
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureID;


    -------------------------------------------------------------------------
    -- 2️⃣ LOAD CROP FROM MANAGEMENT PERIOD
    -------------------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;


    -------------------------------------------------------------------------
    -- 3️⃣ LOAD CROP DETAILS
    -------------------------------------------------------------------------
    SELECT
        @FieldID    = c.FieldID,
        @CropTypeID = c.CropTypeID
    FROM Crops c
    WHERE c.ID = @CropID;


    -------------------------------------------------------------------------
    -- 4️⃣ LOAD FIELD & NVZ
    -------------------------------------------------------------------------
    SELECT
        @IsFieldWithinNVZ = CASE WHEN f.IsWithinNVZ = 1 THEN 1 ELSE 0 END,
        @FarmID = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;


    -------------------------------------------------------------------------
    -- 5️⃣ LOAD FARM COUNTRY
    -------------------------------------------------------------------------
    SELECT @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWelsh   = 1;


    -------------------------------------------------------------------------
    -- 6️⃣ GREEN COMPOST CHECK
    -------------------------------------------------------------------------
    SET @IsGreenCompost =
        CASE WHEN @ManureTypeID IN (24, 32) THEN 1 ELSE 0 END;


    -------------------------------------------------------------------------
    -- 7️⃣ ALLOWED CROP TYPES (110–115)
    -------------------------------------------------------------------------
    SELECT @CropCount = COUNT(*)
    FROM Crops
    WHERE FieldID = @FieldID
      AND CropTypeID IN (110,111,112,113,114,115);

    SET @IsAllowedCrops = CASE WHEN @CropCount > 0 THEN 1 ELSE 0 END;


    -------------------------------------------------------------------------
    -- 8️⃣ 4-YEAR WINDOW
    -------------------------------------------------------------------------
    SET @FourYearsBefore = DATEADD(DAY, -1459, @ApplicationDate);


    -------------------------------------------------------------------------
    -- 9️⃣ TOTAL N = N * ApplicationRate (GREEN COMPOST ONLY)
    -------------------------------------------------------------------------
    SELECT
        @TotalOrganicManureN =
            ISNULL(SUM(om.N * om.ApplicationRate), 0)
    FROM OrganicManures om
    INNER JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    INNER JOIN Crops c ON mp.CropID = c.ID
    WHERE
        c.FieldID = @FieldID
        AND om.ManureTypeID IN (24, 32)
        AND om.ApplicationDate BETWEEN @FourYearsBefore AND @ApplicationDate;


    -------------------------------------------------------------------------
    -- 🔟 APPLY LIMIT (>1000)
    -------------------------------------------------------------------------
    SET @IsTotalNAbove1000 =
        CASE WHEN @TotalOrganicManureN > 1000 THEN 1 ELSE 0 END;


    -------------------------------------------------------------------------
    -- 1️⃣1️⃣ SUMMARY OUTPUT
    -------------------------------------------------------------------------
    SELECT
        @OrganicManureID AS OrganicManureID,
        @FieldID AS FieldID,
        @ApplicationDate AS ApplicationDate,
        @IsFieldWithinNVZ AS IsFieldWithinNVZ,
        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWelsh AS IsFieldInWelsh,
        @IsGreenCompost AS IsGreenCompost,
        @IsAllowedCrops AS IsAllowedCrops,
        @TotalOrganicManureN AS TotalOrganicManureN,
        @IsTotalNAbove1000 AS IsTotalNAboveLimit;


END;