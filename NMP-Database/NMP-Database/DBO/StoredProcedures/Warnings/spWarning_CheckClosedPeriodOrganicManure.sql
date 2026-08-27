
CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodOrganicManure]
    @OrganicManureID INT
AS
BEGIN

SET NOCOUNT ON;

--------------------------------------------------------------------
-- VARIABLES
--------------------------------------------------------------------
DECLARE
    @ManagementPeriodID INT,
    @CropID INT,
    @FieldID INT,
    @FarmID INT,
    @CountryID INT,
    @CropTypeID INT,
    @CropYear INT,
    @SowingDate DATETIME,
    @ApplicationDate DATETIME,
    @ManureTypeID INT,
    @SoilTypeID INT,
    @FieldType INT,
    @CropGroupId INT,
    @N DECIMAL(18,3),

    @IsPerennial BIT = 0,

    @IsFieldInEngland BIT = 0,
    @IsFieldInWelsh BIT = 0,
    @IsFieldInScotland BIT = 0,
    @IsWithinNVZ BIT = 0,
    @RegisteredOrganicProducer BIT = 0,

    @IsHighRanManures BIT = 0,

    @ClosedPeriod NVARCHAR(100),
    @ClosedStartDate DATE,
    @ClosedEndDate DATE,

    @IsWithinClosedPeriod BIT = 0;

DECLARE @ClosedPeriodTable TABLE
(
    ClosedPeriod NVARCHAR(100)
);

DECLARE @ClosedPeriodDates TABLE
(
    ClosedPeriod NVARCHAR(100),
    ClosedStartDate DATE,
    ClosedEndDate DATE
);

--------------------------------------------------------------------
-- 1) Load Organic Manure
--------------------------------------------------------------------
SELECT
    @ManagementPeriodID = om.ManagementPeriodID,
    @ApplicationDate = om.ApplicationDate,
    @ManureTypeID = om.ManureTypeID,
    @N = om.N
FROM OrganicManures om
WHERE om.ID = @OrganicManureID;

--------------------------------------------------------------------
-- 2) ManagementPeriod -> Crop
--------------------------------------------------------------------
SELECT @CropID = mp.CropID
FROM ManagementPeriods mp
WHERE mp.ID = @ManagementPeriodID;

--------------------------------------------------------------------
-- 3) Crop
--------------------------------------------------------------------
SELECT
    @FieldID = c.FieldID,
    @CropTypeID = c.CropTypeID,
    @CropYear = c.Year,
    @SowingDate = c.SowingDate,
    @FieldType = c.FieldType
FROM Crops c
WHERE c.ID = @CropID;

--------------------------------------------------------------------
-- 4) Field
--------------------------------------------------------------------
SELECT
    @SoilTypeID = f.SoilTypeID,
    @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
    @FarmID = f.FarmID
FROM Fields f
WHERE f.ID = @FieldID;

--------------------------------------------------------------------
-- 5) Farm
--------------------------------------------------------------------
SELECT
    @CountryID = fm.CountryID,
    @RegisteredOrganicProducer =
        CASE WHEN ISNULL(fm.RegisteredOrganicProducer,0)=1 THEN 1 ELSE 0 END
FROM Farms fm
WHERE fm.ID = @FarmID;

--------------------------------------------------------------------
-- 6) Country Flags
--------------------------------------------------------------------
SET @IsFieldInEngland  = CASE WHEN @CountryID = 1 THEN 1 ELSE 0 END;
SET @IsFieldInScotland = CASE WHEN @CountryID = 2 THEN 1 ELSE 0 END;
SET @IsFieldInWelsh    = CASE WHEN @CountryID = 3 THEN 1 ELSE 0 END;

--------------------------------------------------------------------
-- 7) High RAN Manure Check
--------------------------------------------------------------------
IF @ManureTypeID IN (8,12,13,14,15,18,45,46,49,51)
    SET @IsHighRanManures = 1;

--------------------------------------------------------------------
-- 8) Get Perennial Flag
--------------------------------------------------------------------
SELECT TOP (1)
    @IsPerennial =
        CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
FROM CropTypeLinkings ctl
WHERE ctl.CropTypeID = @CropTypeID;

--------------------------------------------------------------------
-- 9) GET CLOSED PERIOD TEXT (ALL COUNTRIES)
--------------------------------------------------------------------
INSERT INTO @ClosedPeriodTable
EXEC dbo.spWarning_GetOrganicManureClosedPeriod
    @SoilTypeID = @SoilTypeID,
    @FieldType = @FieldType,
    @HarvestYear = @CropYear,
    @SowingDate = @SowingDate,
    @CountryId = @CountryID,
    @CropGroupId = @CropGroupId,
    @CropTypeId = @CropTypeID,
    @IsPerennial = @IsPerennial;

SELECT @ClosedPeriod = ClosedPeriod
FROM @ClosedPeriodTable;

--------------------------------------------------------------------
-- 10) CONVERT CLOSED PERIOD TEXT → DATES
--------------------------------------------------------------------
INSERT INTO @ClosedPeriodDates
EXEC dbo.spConvertClosedPeriodTextToDates
    @ClosedPeriodText = @ClosedPeriod,
    @HarvestYear = @CropYear;

SELECT
    @ClosedStartDate = ClosedStartDate,
    @ClosedEndDate = ClosedEndDate
FROM @ClosedPeriodDates;

--------------------------------------------------------------------
-- 11) CHECK APPLICATION DATE
--------------------------------------------------------------------
IF @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
    SET @IsWithinClosedPeriod = 1;

--------------------------------------------------------------------
-- FINAL OUTPUT
--------------------------------------------------------------------
SELECT
    @OrganicManureID AS OrganicManureID,
    @ManagementPeriodID AS ManagementPeriodID,
    @CropID AS CropID,
    @FieldID AS FieldID,
    @FarmID AS FarmID,
    @CountryID AS CountryID,
    @IsFieldInEngland AS IsFieldInEngland,
    @IsFieldInScotland AS IsFieldInScotland,
    @IsFieldInWelsh AS IsFieldInWelsh,
    @IsWithinNVZ AS IsWithinNVZ,
    @RegisteredOrganicProducer AS RegisteredOrganicProducer,
    @ManureTypeID AS ManureTypeID,
    @IsHighRanManures AS IsHighRanManures,
    @CropTypeID AS CropTypeID,
    @SoilTypeID AS SoilTypeID,
    @FieldType AS FieldType,
    @SowingDate AS SowingDate,
    @ApplicationDate AS ApplicationDate,
    @ClosedPeriod AS ClosedPeriod,
    @ClosedStartDate AS ClosedPeriodStart,
    @ClosedEndDate AS ClosedPeriodEnd,
    @IsWithinClosedPeriod AS IsWithinClosedPeriod,
    @N AS OrganicManureN;

END