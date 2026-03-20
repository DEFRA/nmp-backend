/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
 					
--------------------------------------------------------------------------------------
*/
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'StoreCapacities' AND TABLE_SCHEMA = 'DBO')
BEGIN
    IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'StoreCapacities' AND COLUMN_NAME = 'SolidManureTypeID' AND TABLE_SCHEMA = 'DBO')
    BEGIN
        IF EXISTS(SELECT 1 FROM StoreCapacities WHERE SolidManureTypeID = 10)
        BEGIN
            UPDATE StoreCapacities SET SolidManureTypeID = 9 WHERE SolidManureTypeID = 10
        END
    END    
END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SolidManureTypes' AND TABLE_SCHEMA = 'DBO')
BEGIN
     IF EXISTS(SELECT 1 FROM SolidManureTypes WHERE ID = 10)
     BEGIN
         DELETE FROM SolidManureTypes WHERE ID = 10
     END
END

GO -- do not remove this GO