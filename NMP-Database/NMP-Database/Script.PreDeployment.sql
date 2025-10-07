/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Countries' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Countries' AND COLUMN_NAME = 'RB209CountryID' AND TABLE_SCHEMA = 'DBO')
--	BEGIN 
--		PRINT 'Column NOT exists';
--		TRUNCATE TABLE [Countries];
--	END
--END

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SoilAnalyses' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SoilAnalyses' AND COLUMN_NAME = 'PotassiumIndex' AND TABLE_SCHEMA = 'DBO')
--    BEGIN 
--        PRINT 'Column data type change';
--        ALTER TABLE DBO.SoilAnalyses
--        ALTER COLUMN PotassiumIndex SMALLINT; 
--    END
--END
--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OrganicManures' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrganicManures' AND COLUMN_NAME = 'ApplicationRate' AND TABLE_SCHEMA = 'DBO')
--    BEGIN 
--        PRINT 'Column data type change';
--        ALTER TABLE DBO.OrganicManures
--        ALTER COLUMN ApplicationRate DECIMAL(18,1); 
--    END
--END

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SnsAnalyses' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SnsAnalyses' AND COLUMN_NAME = 'FieldID' AND TABLE_SCHEMA = 'DBO')
--	BEGIN 
--		PRINT 'FieldId Column exists';
--		TRUNCATE TABLE [SnsAnalyses];
--	END
--END


--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CropTypeLinkings' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CropTypeLinkings' AND COLUMN_NAME = 'SNSCategoryID' AND TABLE_SCHEMA = 'DBO')
--    BEGIN 
--        PRINT 'CropTypeLinkings data change';
--        DROP TABLE [CropTypeLinkings];
--    END
--END

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SNSCategories' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SNSCategories' AND COLUMN_NAME = 'ID' AND TABLE_SCHEMA = 'DBO')
--    BEGIN 
--        PRINT 'SNSCategories data change';
--        DROP TABLE [SNSCategories];
--    END
--END

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PKBalances' AND TABLE_SCHEMA = 'DBO')
--BEGIN
     
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PKBalances' AND COLUMN_NAME = 'CreatedOn' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        PRINT 'Changing NOT NULL to NULL for CreatedOn column';
--        ALTER TABLE DBO.PKBalances
--        ALTER COLUMN [CreatedOn] DATETIME2 NULL;
--    END
    
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PKBalances' AND COLUMN_NAME = 'CreatedByID' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        PRINT 'Changing NOT NULL to NULL for CreatedByID column';
--        ALTER TABLE DBO.PKBalances
--        ALTER COLUMN CreatedByID INT NULL;
--    END
--END

--GO

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Crops' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Crops' AND COLUMN_NAME = 'DefoliationSequence' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        PRINT 'Changing COLUMN NAME DefoliationSequence to DefoliationSequenceID';
--        EXEC sp_rename 'Crops.DefoliationSequence', 'DefoliationSequenceID', 'COLUMN';
--    END
--    IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Crops' AND COLUMN_NAME = 'SwardTypeID' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        PRINT 'Add COLUMN';
--        ALTER TABLE Crops
--        ADD SwardTypeID INT NULL;
--    END
--    IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Crops' AND COLUMN_NAME = 'SwardManagementID' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        PRINT 'Add COLUMN';
--        ALTER TABLE Crops
--        ADD SwardManagementID INT NULL;
--    END
--    IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Crops' AND COLUMN_NAME = 'PotentialCut' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        PRINT 'Add COLUMN';
--        ALTER TABLE Crops
--        ADD PotentialCut INT NULL;
--    END
        
--END

--GO

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ManagementPeriods' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ManagementPeriods' AND COLUMN_NAME = 'DefoliationID' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        PRINT 'Changing COLUMN NAME DefoliationID to Defoliation';
--        EXEC sp_rename 'ManagementPeriods.DefoliationID', 'Defoliation', 'COLUMN';
--    END
--END

--GO

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CropTypeLinkings' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CropTypeLinkings' AND COLUMN_NAME = 'NMaxLimitEngland' AND TABLE_SCHEMA = 'DBO')
--    BEGIN
--        IF EXISTS(SELECT 1 FROM CropTypeLinkings WHERE NMaxLimitEngland IS NULL AND CropTypeID=77)
--        BEGIN
--            UPDATE CropTypeLinkings SET NMaxLimitEngland=280, NMaxLimitWales=250 WHERE CropTypeID=77
--        END
--    END    
--END

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PreviousGrassIdMapping' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PreviousGrassIdMapping' AND COLUMN_NAME = 'IsCutOnly' AND TABLE_SCHEMA = 'DBO')
--	BEGIN 
--		PRINT 'IsCutOnly Column NOT exists in PreviousGrassIdMapping table';
--		TRUNCATE TABLE [PreviousGrassIdMapping];
--	END
--END


--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LivestockTypes' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--   TRUNCATE TABLE [LivestockTypes];
--END

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LivestockGroups' AND TABLE_SCHEMA = 'DBO')
--BEGIN
--	TRUNCATE TABLE [LivestockGroups];
--END

--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Crops' AND TABLE_SCHEMA = 'dbo')
--BEGIN

--    -- Step 1: get all duplicate entries
--    WITH DuplicateCrops AS (
--        SELECT 
--            Id,
--            ROW_NUMBER() OVER (
--                PARTITION BY FieldId, [Year], CropTypeID, CropOrder
--                ORDER BY Id
--            ) AS rn
--        FROM dbo.Crops
--    )

--    -- Store duplicate Ids into Id (remove the ist entry)
--    SELECT Id 
--    INTO #DuplicateCropIds
--    FROM DuplicateCrops
--    WHERE rn > 1;

--    -- Step 3: delete duplicate ids using stored procedure
--    DECLARE @CropId INT;

--    WHILE EXISTS (SELECT 1 FROM #DuplicateCropIds)
--    BEGIN
--        SELECT TOP 1 @CropId = Id FROM #DuplicateCropIds;

--        EXEC [spCrops_DeleteCrops] @CropId;

--        DELETE FROM #DuplicateCropIds WHERE Id = @CropId;
--    END

--    DROP TABLE #DuplicateCropIds;
--END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'NutrientsLoadingLiveStocks' AND TABLE_SCHEMA = 'DBO')
BEGIN
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NutrientsLoadingLiveStocks' AND COLUMN_NAME = 'NByUnit'  AND (
           DATA_TYPE <> 'decimal'
           OR NUMERIC_PRECISION <> 18
           OR NUMERIC_SCALE <> 6
      ) AND TABLE_SCHEMA = 'DBO')
    BEGIN 
        PRINT 'Column data type change';
        ALTER TABLE DBO.NutrientsLoadingLiveStocks
        ALTER COLUMN NByUnit DECIMAL(18,6); 
    END

       IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NutrientsLoadingLiveStocks' AND COLUMN_NAME = 'PByUnit'  AND (
           DATA_TYPE <> 'decimal'
           OR NUMERIC_PRECISION <> 18
           OR NUMERIC_SCALE <> 6
      ) AND TABLE_SCHEMA = 'DBO')
    BEGIN 
        PRINT 'Column data type change';
        ALTER TABLE DBO.NutrientsLoadingLiveStocks
        ALTER COLUMN PByUnit DECIMAL(18,6); 
    END
END


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OrganicManures' AND TABLE_SCHEMA = 'DBO')
BEGIN
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrganicManures' AND COLUMN_NAME = 'AutumnCropNitrogenUptake' AND TABLE_SCHEMA = 'DBO')
    BEGIN 
        PRINT 'Dropped existing default constraint';
        ALTER TABLE DBO.OrganicManures
        DROP CONSTRAINT DF_OrganicManures_AutumnCropNitrogenUptake;
        
		PRINT 'Column data type change';
        ALTER TABLE DBO.OrganicManures
        ALTER COLUMN AutumnCropNitrogenUptake INT; 

		PRINT 'Add default constraint';
		ALTER TABLE DBO.OrganicManures
        ADD CONSTRAINT DF_OrganicManures_AutumnCropNitrogenUptake DEFAULT 0 FOR AutumnCropNitrogenUptake;
    END
END

GO