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
