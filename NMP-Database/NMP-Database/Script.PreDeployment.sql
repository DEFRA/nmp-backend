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
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Countries' AND TABLE_SCHEMA = 'DBO')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Countries' AND COLUMN_NAME = 'RB209CountryID' AND TABLE_SCHEMA = 'DBO')
	BEGIN 
		PRINT 'Column NOT exists';
		TRUNCATE TABLE [Countries];
	END
END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SoilAnalyses' AND TABLE_SCHEMA = 'DBO')
BEGIN
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SoilAnalyses' AND COLUMN_NAME = 'PotassiumIndex' AND TABLE_SCHEMA = 'DBO')
    BEGIN 
        PRINT 'Column data type change';
        ALTER TABLE DBO.SoilAnalyses
        ALTER COLUMN PotassiumIndex SMALLINT; 
    END
END
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OrganicManures' AND TABLE_SCHEMA = 'DBO')
BEGIN
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrganicManures' AND COLUMN_NAME = 'ApplicationRate' AND TABLE_SCHEMA = 'DBO')
    BEGIN 
        PRINT 'Column data type change';
        ALTER TABLE DBO.OrganicManures
        ALTER COLUMN ApplicationRate DECIMAL(18,1); 
    END
END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SnsAnalyses' AND TABLE_SCHEMA = 'DBO')
BEGIN
	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SnsAnalyses' AND COLUMN_NAME = 'FieldID' AND TABLE_SCHEMA = 'DBO')
	BEGIN 
		PRINT 'FieldId Column exists';
		TRUNCATE TABLE [SnsAnalyses];
	END
END


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CropTypeLinkings' AND TABLE_SCHEMA = 'DBO')
BEGIN
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CropTypeLinkings' AND COLUMN_NAME = 'SNSCategoryID' AND TABLE_SCHEMA = 'DBO')
    BEGIN 
        PRINT 'CropTypeLinkings data change';
        DROP TABLE [CropTypeLinkings];
    END
END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SNSCategories' AND TABLE_SCHEMA = 'DBO')
BEGIN
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SNSCategories' AND COLUMN_NAME = 'ID' AND TABLE_SCHEMA = 'DBO')
    BEGIN 
        PRINT 'SNSCategories data change';
        DROP TABLE [SNSCategories];
    END
END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PKBalances' AND TABLE_SCHEMA = 'DBO')
BEGIN
     
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PKBalances' AND COLUMN_NAME = 'CreatedOn' AND TABLE_SCHEMA = 'DBO')
    BEGIN
        PRINT 'Changing NOT NULL to NULL for CreatedOn column';
        ALTER TABLE DBO.PKBalances
        ALTER COLUMN [CreatedOn] DATETIME2 NULL;
    END
    
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PKBalances' AND COLUMN_NAME = 'CreatedByID' AND TABLE_SCHEMA = 'DBO')
    BEGIN
        PRINT 'Changing NOT NULL to NULL for CreatedByID column';
        ALTER TABLE DBO.PKBalances
        ALTER COLUMN CreatedByID INT NULL;
    END
END