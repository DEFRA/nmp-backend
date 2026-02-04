

CREATE PROCEDURE [dbo].[spWarning_CheckOrganicManureNFieldLimitYear]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES
    --------------------------------------------------------------------
    DECLARE 
        @FieldId INT,
        @CropId INT,
        @ManagementPeriodId INT,
        @FarmId INT,
        @ApplicationDate DATETIME,

        @OneYearBefore DATETIME,
        @TotalOrganicManureNitrogen DECIMAL(18, 3),

        @IsOrganicManureNFieldLimit BIT = 0,
        @IsWithinNvz BIT = 0,
        @IsFieldEngland BIT = 0,
        @IsFieldWelsh BIT = 0;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure → Get ManagementPeriod & ApplicationDate
    --------------------------------------------------------------------
    SELECT 
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = om.ApplicationDate
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;


    --------------------------------------------------------------------
    -- 2) Load Crop
    --------------------------------------------------------------------
    SELECT 
        @CropId = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodId;


    --------------------------------------------------------------------
    -- 3) Load Field
    --------------------------------------------------------------------
    SELECT 
        @FieldId = c.FieldID
    FROM Crops c
    WHERE c.ID = @CropId;


    --------------------------------------------------------------------
    -- 4) Field & Farm Details
    --------------------------------------------------------------------
    SELECT 
        @IsWithinNvz = CASE WHEN f.IsWithinNVZ = 1 THEN 1 ELSE 0 END,
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------------------
    -- 5) Country flags (England = 1, Wales = 3)
    --------------------------------------------------------------------
    SELECT
        @IsFieldEngland = CASE WHEN fm.CountryID = 1 THEN 1 ELSE 0 END,
        @IsFieldWelsh   = CASE WHEN fm.CountryID = 3 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmId;


    --------------------------------------------------------------------
    -- 6) 1-Year Window
    --------------------------------------------------------------------
    SET @OneYearBefore = DATEADD(DAY, -364, @ApplicationDate);


    --------------------------------------------------------------------
    -- 7) Compute Total Nitrogen (N * ApplicationRate)
    --     Excluding compost types (24, 32)
    --------------------------------------------------------------------
    SELECT 
        @TotalOrganicManureNitrogen =
            ISNULL(SUM(om.N * om.ApplicationRate), 0)
    FROM OrganicManures om
    INNER JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    INNER JOIN Crops c ON mp.CropID = c.ID
    WHERE 
        c.FieldID = @FieldId
        AND om.ApplicationDate BETWEEN @OneYearBefore AND @ApplicationDate
        AND om.ManureTypeID NOT IN (24, 32);


    --------------------------------------------------------------------
    -- 8) Check limit > 250
    --------------------------------------------------------------------
    SET @IsOrganicManureNFieldLimit = 
        CASE WHEN @TotalOrganicManureNitrogen > 250 THEN 1 ELSE 0 END;


    --------------------------------------------------------------------
    -- 9) RETURN SUMMARY
    --------------------------------------------------------------------
    SELECT 
        @OrganicManureId AS OrganicManureId,
        @FieldId AS FieldId,
        @ApplicationDate AS ApplicationDate,
        @IsWithinNvz AS IsWithinNvz,
        @IsFieldEngland AS IsFieldEngland,
        @IsFieldWelsh AS IsFieldWelsh,
        @TotalOrganicManureNitrogen AS TotalOrganicManureNitrogen,
        @IsOrganicManureNFieldLimit AS IsOrganicManureNFieldLimit;


    --------------------------------------------------------------------
    -- 10) RETURN DETAILED MANURE LIST
    --------------------------------------------------------------------
    SELECT 
        om.ID,
        om.ManagementPeriodID,
        om.ManureTypeID,
        om.ManureTypeName,
        om.ApplicationDate,
        om.N,
        om.ApplicationRate,
        (om.N * om.ApplicationRate) AS AppliedNitrogen
    FROM OrganicManures om
    INNER JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    INNER JOIN Crops c ON mp.CropID = c.ID
    WHERE 
        c.FieldID = @FieldId
        AND om.ApplicationDate BETWEEN @OneYearBefore AND @ApplicationDate
        AND om.ManureTypeID NOT IN (24, 32);

END;