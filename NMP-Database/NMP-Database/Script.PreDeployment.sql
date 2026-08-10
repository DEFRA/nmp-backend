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

 -- 01-04-2026
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Warnings' AND TABLE_SCHEMA = 'dbo')
BEGIN
    TRUNCATE TABLE Warnings
END

-- 01-04-2026
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'CropTypeLinkings' 
             AND TABLE_SCHEMA = 'dbo' 
             AND COLUMN_NAME = 'NMaxLimitScotland')
BEGIN
    ALTER TABLE dbo.CropTypeLinkings
    DROP COLUMN NMaxLimitScotland;
END

--10-04-2026
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ScotlandNMaxValues' AND TABLE_SCHEMA = 'dbo')
BEGIN
    IF (SELECT COUNT(*) FROM ScotlandNMaxValues) = 162
    BEGIN
        TRUNCATE TABLE ScotlandNMaxValues
    END
END

--30-07-2026
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Recommendations' AND TABLE_SCHEMA = 'dbo')
BEGIN   
            UPDATE Recommendations
            SET IsSacMethodology = 0
            WHERE IsSacMethodology IS NULL;

            ALTER TABLE Recommendations
            ALTER COLUMN IsSacMethodology BIT NOT NULL;
END

--04-08-2026
/*========================================================
    Migration: Separate Farm Details into MannerFarms Table
========================================================*/

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      Step 1: Create MannerFarms Table
    ====================================================*/

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.tables
        WHERE name = 'MannerFarms'
          AND schema_id = SCHEMA_ID('dbo')
    )
    BEGIN

        CREATE TABLE dbo.MannerFarms
        (
            ID INT IDENTITY(1,1) PRIMARY KEY,
            OrganisationID UNIQUEIDENTIFIER NOT NULL,
            [Name] NVARCHAR(250) NOT NULL,
            CountryID INT NOT NULL,
            Postcode NVARCHAR(50) NULL,
            AverageAnuualRainfall INT NULL,
             RegisteredOrganicProducer BIT NOT NULL CONSTRAINT DF_MannerFarms_RegisteredOrganicProducer DEFAULT (0),
            [CreatedOn] DATETIME2 NULL CONSTRAINT DF_MannerFarms_CreatedOn DEFAULT GETDATE(), 
            [CreatedByID] INT NULL,
	        [ModifiedOn] DATETIME2 NULL,
	        [ModifiedByID] INT NULL,

            CONSTRAINT FK_MannerFarms_Countries
            FOREIGN KEY (CountryID)
            REFERENCES dbo.Countries(ID),

            CONSTRAINT FK_MannerFarms_Organisations
            FOREIGN KEY (OrganisationID)
            REFERENCES dbo.Organisations(ID),

            CONSTRAINT UQ_MannerFarms_Name_OrganisationID
            UNIQUE ([Name], [OrganisationID]),
            CONSTRAINT [FK_MannerFarms_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [Users]([ID]),
            CONSTRAINT [FK_MannerFarms_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [Users]([ID])
        );

    END;



    /*====================================================
      Step 2: Copy Unique Farm Data
      Unique based on OrganisationID + FarmName
    ====================================================*/

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.MannerFarms
    )
    BEGIN

        ;WITH FarmCTE AS
        (
            SELECT
                OrganisationID,
                FarmName,
                CountryID,
                Postcode,
                AverageAnuualRainfall,
                RegisteredOrganicProducer,
                CreatedOn,
                CreatedByID,
                ROW_NUMBER() OVER
                (
                    PARTITION BY OrganisationID, FarmName
                    ORDER BY ID
                ) AS RowNum
            FROM dbo.MannerEstimations
        )
        INSERT INTO dbo.MannerFarms
        (
            OrganisationID,
            [Name],
            CountryID,
            Postcode,
            AverageAnuualRainfall,
            RegisteredOrganicProducer,
            CreatedOn,
            CreatedByID
        )
        SELECT
            OrganisationID,
            FarmName,
            CountryID,
            Postcode,
            AverageAnuualRainfall,
            RegisteredOrganicProducer,
            CreatedOn,
            CreatedByID
        FROM FarmCTE
        WHERE RowNum = 1;

    END;



    /*====================================================
      Step 3: Add FarmID Column
    ====================================================*/
    DECLARE @MannerEstimationsTableName SYSNAME = 'dbo.MannerEstimations';
    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.columns
        WHERE name = 'FarmID'
          AND object_id = OBJECT_ID(@MannerEstimationsTableName)
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        ADD MannerFarmID INT NULL;

    END;



    /*====================================================
      Step 4: Update FarmID
    ====================================================*/

    UPDATE ME
    SET MannerFarmID = MF.ID
    FROM dbo.MannerEstimations ME
    INNER JOIN dbo.MannerFarms MF
        ON MF.OrganisationID = ME.OrganisationID
       AND MF.[Name] = ME.FarmName;



    /*====================================================
      Step 5: Make FarmID NOT NULL
    ====================================================*/

    ALTER TABLE dbo.MannerEstimations
    ALTER COLUMN MannerFarmID INT NOT NULL;



    /*====================================================
      Step 6: Create Farm Foreign Key
    ====================================================*/

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_MannerEstimations_MannerFarms'
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        ADD CONSTRAINT FK_MannerEstimations_MannerFarms
        FOREIGN KEY (FarmID)
        REFERENCES dbo.MannerFarms(ID);

    END;

     IF NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE name = 'UQ_MannerEstimations_Name_MannerFarmID'
          AND parent_object_id = OBJECT_ID('dbo.MannerEstimations')
    )
    BEGIN
        ALTER TABLE [dbo].[MannerEstimations]
        ADD CONSTRAINT [UQ_MannerEstimations_Name_MannerFarmID]
            UNIQUE ([Name], [MannerFarmID]);
    END


    /*====================================================
      Step 7: Drop Old Constraints
    ====================================================*/
IF EXISTS 
(
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(@MannerEstimationsTableName) 
    AND name = 'RegisteredOrganicProducer'
)
BEGIN 
    ALTER TABLE dbo.MannerEstimations 
    DROP CONSTRAINT DF_MannerEstimations_RegisteredOrganicProducer; 
END;
    IF EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_MannerEstimations_Countries'
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        DROP CONSTRAINT FK_MannerEstimations_Countries;

    END;


    IF EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_MannerEstimations_Organisations'
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        DROP CONSTRAINT FK_MannerEstimations_Organisations;

    END;


    IF EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE name = 'UQ_MannerEstimations_Name_OrganisationID'
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        DROP CONSTRAINT UQ_MannerEstimations_Name_OrganisationID;

    END;
       


    /*====================================================
      Step 8: Drop Old Farm Columns
    ====================================================*/

    IF EXISTS
    (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID(@MannerEstimationsTableName)
          AND name = 'FarmName'
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        DROP COLUMN
            OrganisationID,
            FarmName,
            CountryID,
            Postcode,
            AverageAnuualRainfall,
            RegisteredOrganicProducer;

    END;



    COMMIT TRANSACTION;


    PRINT 'Migration completed successfully.';


END TRY


BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();

    THROW;

END CATCH;



/*====================================================
  Verification
====================================================*/


--10-08-2026
BEGIN TRANSACTION;

BEGIN TRY

    -- Column rename
    EXEC sp_rename
        'dbo.MannerEstimations.FarmID',
        'MannerFarmID',
        'COLUMN';

 IF EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE name = 'UQ_MannerEstimations_Name_FarmID'
      AND parent_object_id = OBJECT_ID('dbo.MannerEstimations')
)
BEGIN
    -- Old constraint exists -> rename it
    EXEC sp_rename
        'dbo.MannerEstimations.UQ_MannerEstimations_Name_FarmID',
        'UQ_MannerEstimations_Name_MannerFarmID',
        'OBJECT';
END
ELSE IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE name = 'UQ_MannerEstimations_Name_MannerFarmID'
      AND parent_object_id = OBJECT_ID('dbo.MannerEstimations')
)
BEGIN
    -- Neither old nor new constraint exists -> add new constraint
    ALTER TABLE [dbo].[MannerEstimations]
    ADD CONSTRAINT [UQ_MannerEstimations_Name_MannerFarmID]
        UNIQUE ([Name], [MannerFarmID]);
END

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;
    THROW;

END CATCH;

GO -- do not remove this GO