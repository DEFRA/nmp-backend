



CREATE PROCEDURE [dbo].[spWarning_CheckOrganicManureNFieldLimitComposts]
    @OrganicManureID INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES
    --------------------------------------------------------------------
    DECLARE
        @FieldId INT,
        @CropId INT,
        @FarmId INT,
        @CropTypeId INT,
        @ApplicationDate DATETIME,
        @ManureTypeId INT,

        @TwoYearsBefore DATETIME,
        @TotalOrganicManureNitrogen DECIMAL(18,3),

        @IsFieldWithinNvz BIT = 0,
        @IsFieldEngland BIT = 0,
        @IsFieldWelsh BIT = 0,
        @IsTotalNitrogenAboveLimit BIT = 0,
        @IsRestrictedCropNotPresent BIT = 0,
        @IsGreenCompost BIT = 0,

        @CropCount INT;

    --------------------------------------------------------------------
    -- 1️⃣ LOAD CURRENT ORGANIC MANURE + CONTEXT
    --------------------------------------------------------------------
    SELECT
        @ApplicationDate = om.ApplicationDate,
        @ManureTypeId = om.ManureTypeID,
        @CropId = mp.CropID,
        @FieldId = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @FarmId = f.FarmID,
        @IsFieldWithinNvz = CASE WHEN f.IsWithinNVZ = 1 THEN 1 ELSE 0 END
    FROM OrganicManures om
    INNER JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    INNER JOIN Crops c ON mp.CropID = c.ID
    INNER JOIN Fields f ON c.FieldID = f.ID
    WHERE om.ID = @OrganicManureID;

    --------------------------------------------------------------------
    -- 2️⃣ COUNTRY FLAGS
    --------------------------------------------------------------------
    SELECT
        @IsFieldEngland = CASE WHEN fm.CountryID = 1 THEN 1 ELSE 0 END,
        @IsFieldWelsh   = CASE WHEN fm.CountryID = 3 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmId;

    --------------------------------------------------------------------
    -- 3️⃣ GREEN COMPOST CHECK
    --------------------------------------------------------------------
    SET @IsGreenCompost =
        CASE WHEN @ManureTypeId IN (24, 32) THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 4️⃣ TWO-YEAR WINDOW
    --------------------------------------------------------------------
    SET @TwoYearsBefore = DATEADD(DAY, -729, @ApplicationDate);

    --------------------------------------------------------------------
    -- 5️⃣ RESTRICTED CROP TYPES CHECK (110–115)
    --------------------------------------------------------------------


    SET @IsRestrictedCropNotPresent =
        CASE WHEN @CropTypeId IN (110,111,112,113,114,115) THEN 0 ELSE 1 END;

    --------------------------------------------------------------------
    -- 6️⃣ TOTAL GREEN COMPOST N (N * ApplicationRate) — LAST 2 YEARS
    --------------------------------------------------------------------
    SELECT 
        @TotalOrganicManureNitrogen =
            ISNULL(SUM(om.N * om.ApplicationRate), 0)
    FROM OrganicManures om
    INNER JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    INNER JOIN Crops c ON mp.CropID = c.ID
    WHERE 
        c.FieldID = @FieldId
        AND om.ManureTypeID IN (24, 32)   -- Green compost only
        AND om.ApplicationDate BETWEEN @TwoYearsBefore AND @ApplicationDate;

    --------------------------------------------------------------------
    -- 7️⃣ LIMIT CHECK (> 500 kg N)
    --------------------------------------------------------------------
    SET @IsTotalNitrogenAboveLimit =
        CASE WHEN @TotalOrganicManureNitrogen > 500 THEN 1 ELSE 0 END;

    --------------------------------------------------------------------
    -- 8️⃣ SUMMARY OUTPUT
    --------------------------------------------------------------------
    SELECT
        @OrganicManureID AS OrganicManureID,
        @FieldId AS FieldId,
        @CropId AS CropId,
        @CropTypeId AS CropTypeId,
        @ApplicationDate AS ApplicationDate,

        @IsFieldWithinNvz AS IsFieldWithinNvz,
        @IsFieldEngland AS IsFieldEngland,
        @IsFieldWelsh AS IsFieldWelsh,

        @IsGreenCompost AS IsGreenCompost,
        @TotalOrganicManureNitrogen AS TotalOrganicManureNitrogen,
        @IsTotalNitrogenAboveLimit AS IsTotalNitrogenAboveLimit,
        @IsRestrictedCropNotPresent AS IsRestrictedCropNotPresent,
		@CropCount AS CropCount

END;