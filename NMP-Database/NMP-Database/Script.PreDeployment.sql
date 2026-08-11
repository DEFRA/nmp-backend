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
/*====================================================*
    Migration: Separate Farm Details into MannerFarms
*====================================================*/

DECLARE @MannerFarmsTableName SYSNAME =
    N'dbo.MannerFarms';

DECLARE @MannerEstimationsTableName SYSNAME =
    N'dbo.MannerEstimations';

DECLARE @CRLF NVARCHAR(2) =
    CHAR(13) + CHAR(10);


/*====================================================*
    Reusable SQL fragments
*====================================================*/

DECLARE @OrganisationIDColumn NVARCHAR(100) =
    N'    OrganisationID,' + @CRLF;

DECLARE @FarmNameColumn NVARCHAR(100) =
    N'    FarmName,' + @CRLF;

DECLARE @CountryIDColumn NVARCHAR(100) =
    N'    CountryID,' + @CRLF;

DECLARE @PostcodeColumn NVARCHAR(100) =
    N'    Postcode,' + @CRLF;

DECLARE @AverageAnuualRainfallColumn NVARCHAR(150) =
    N'    AverageAnuualRainfall,' + @CRLF;

DECLARE @RegisteredOrganicProducerColumn NVARCHAR(150) =
    N'    RegisteredOrganicProducer,' + @CRLF;

DECLARE @CreatedOnColumn NVARCHAR(100) =
    N'    CreatedOn,' + @CRLF;

DECLARE @CreatedByIDColumn NVARCHAR(100) =
    N'    CreatedByID' + @CRLF;

DECLARE @AlterMannerEstimations NVARCHAR(200) =
    N'ALTER TABLE dbo.MannerEstimations' + @CRLF;


/*====================================================*
    MAIN MIGRATION
*====================================================*/

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      If MannerFarms already exists:
      DO NOTHING in main migration
    ====================================================*/

    IF OBJECT_ID(@MannerFarmsTableName, 'U') IS NOT NULL
    BEGIN

        PRINT 'MannerFarms table already exists.';
        PRINT 'Main migration skipped.';

    END
    ELSE
    BEGIN

        PRINT 'MannerFarms table does not exist.';
        PRINT 'Starting migration...';


        DECLARE @Sql NVARCHAR(MAX);
        DECLARE @UnmappedCount INT = 0;
        DECLARE @MigrationFailed BIT = 0;


        /*====================================================
          Step 1: Create MannerFarms
        ====================================================*/

        SET @Sql =
              N'CREATE TABLE dbo.MannerFarms' + @CRLF
            + N'(' + @CRLF
            + N'    ID INT IDENTITY(1,1) PRIMARY KEY,' + @CRLF
            + N'    OrganisationID UNIQUEIDENTIFIER NOT NULL,' + @CRLF
            + N'    [Name] NVARCHAR(250) NOT NULL,' + @CRLF
            + N'    CountryID INT NOT NULL,' + @CRLF
            + N'    Postcode NVARCHAR(50) NULL,' + @CRLF
            + N'    AverageAnuualRainfall INT NULL,' + @CRLF
            + N'    RegisteredOrganicProducer BIT NOT NULL' + @CRLF
            + N'        CONSTRAINT DF_MannerFarms_RegisteredOrganicProducer' + @CRLF
            + N'        DEFAULT (0),' + @CRLF
            + N'    [CreatedOn] DATETIME2 NULL' + @CRLF
            + N'        CONSTRAINT DF_MannerFarms_CreatedOn' + @CRLF
            + N'        DEFAULT GETDATE(),' + @CRLF
            + N'    [CreatedByID] INT NULL,' + @CRLF
            + N'    [ModifiedOn] DATETIME2 NULL,' + @CRLF
            + N'    [ModifiedByID] INT NULL,' + @CRLF
            + N'    CONSTRAINT FK_MannerFarms_Countries' + @CRLF
            + N'        FOREIGN KEY (CountryID)' + @CRLF
            + N'        REFERENCES dbo.Countries(ID),' + @CRLF
            + N'    CONSTRAINT FK_MannerFarms_Organisations' + @CRLF
            + N'        FOREIGN KEY (OrganisationID)' + @CRLF
            + N'        REFERENCES dbo.Organisations(ID),' + @CRLF
            + N'    CONSTRAINT UQ_MannerFarms_Name_OrganisationID' + @CRLF
            + N'        UNIQUE ([Name], [OrganisationID]),' + @CRLF
            + N'    CONSTRAINT FK_MannerFarms_Users_CreatedBy' + @CRLF
            + N'        FOREIGN KEY ([CreatedByID])' + @CRLF
            + N'        REFERENCES dbo.Users([ID]),' + @CRLF
            + N'    CONSTRAINT FK_MannerFarms_Users_ModifiedBy' + @CRLF
            + N'        FOREIGN KEY ([ModifiedByID])' + @CRLF
            + N'        REFERENCES dbo.Users([ID])' + @CRLF
            + N');';

        EXEC sys.sp_executesql @Sql;


        /*====================================================
          Step 2: Copy Unique Farm Data
        ====================================================*/

        SET @Sql =
              N';WITH FarmCTE AS' + @CRLF
            + N'(' + @CRLF
            + N'    SELECT' + @CRLF
            + @OrganisationIDColumn
            + @FarmNameColumn
            + @CountryIDColumn
            + @PostcodeColumn
            + @AverageAnuualRainfallColumn
            + @RegisteredOrganicProducerColumn
            + @CreatedOnColumn
            + @CreatedByIDColumn
            + N'        ROW_NUMBER() OVER' + @CRLF
            + N'        (' + @CRLF
            + N'            PARTITION BY OrganisationID, FarmName' + @CRLF
            + N'            ORDER BY ID' + @CRLF
            + N'        ) AS RowNum' + @CRLF
            + N'    FROM dbo.MannerEstimations' + @CRLF
            + N')' + @CRLF
            + N'INSERT INTO dbo.MannerFarms' + @CRLF
            + N'(' + @CRLF
            + @OrganisationIDColumn
            + N'    [Name],' + @CRLF
            + @CountryIDColumn
            + @PostcodeColumn
            + @AverageAnuualRainfallColumn
            + @RegisteredOrganicProducerColumn
            + @CreatedOnColumn
            + @CreatedByIDColumn
            + N')' + @CRLF
            + N'SELECT' + @CRLF
            + @OrganisationIDColumn
            + @FarmNameColumn
            + @CountryIDColumn
            + @PostcodeColumn
            + @AverageAnuualRainfallColumn
            + @RegisteredOrganicProducerColumn
            + @CreatedOnColumn
            + @CreatedByIDColumn
            + N'FROM FarmCTE' + @CRLF
            + N'WHERE RowNum = 1;';

        EXEC sys.sp_executesql @Sql;


        /*====================================================
          Step 3: Add MannerFarmID
        ====================================================*/

        SET @Sql =
              @AlterMannerEstimations
            + N'ADD MannerFarmID INT NULL;';

        EXEC sys.sp_executesql @Sql;


        /*====================================================
          Step 4: Update MannerFarmID
        ====================================================*/

        SET @Sql =
              N'UPDATE ME' + @CRLF
            + N'SET MannerFarmID = MF.ID' + @CRLF
            + N'FROM dbo.MannerEstimations AS ME' + @CRLF
            + N'INNER JOIN dbo.MannerFarms AS MF' + @CRLF
            + N'    ON MF.OrganisationID = ME.OrganisationID' + @CRLF
            + N'   AND MF.[Name] = ME.FarmName;';

        EXEC sys.sp_executesql @Sql;


        /*====================================================
          Step 5: Check Unmapped Records
        ====================================================*/

        SET @Sql =
              N'SELECT @Count = COUNT(*)' + @CRLF
            + N'FROM dbo.MannerEstimations' + @CRLF
            + N'WHERE MannerFarmID IS NULL;';

        EXEC sys.sp_executesql
            @Sql,
            N'@Count INT OUTPUT',
            @Count = @UnmappedCount OUTPUT;


        IF @UnmappedCount > 0
        BEGIN

            PRINT 'Migration failed.';
            PRINT 'Unmapped records: '
                + CAST(@UnmappedCount AS VARCHAR(20));

            SET @MigrationFailed = 1;

        END;


        /*====================================================
          Continue only if all records were mapped
        ====================================================*/

        IF @MigrationFailed = 0
        BEGIN


            /*================================================
              Step 6: Make MannerFarmID NOT NULL
            ================================================*/

            SET @Sql =
                  @AlterMannerEstimations
                + N'ALTER COLUMN MannerFarmID INT NOT NULL;';

            EXEC sys.sp_executesql @Sql;


            /*================================================
              Step 7: Create Foreign Key
            ================================================*/

            SET @Sql =
                  @AlterMannerEstimations
                + N'ADD CONSTRAINT FK_MannerEstimations_MannerFarms'
                + @CRLF
                + N'    FOREIGN KEY (MannerFarmID)'
                + @CRLF
                + N'    REFERENCES dbo.MannerFarms(ID);';

            EXEC sys.sp_executesql @Sql;


            /*================================================
              Step 8: Create Unique Constraint
            ================================================*/

            SET @Sql =
                  @AlterMannerEstimations
                + N'ADD CONSTRAINT UQ_MannerEstimations_Name_MannerFarmID'
                + @CRLF
                + N'    UNIQUE ([Name], MannerFarmID);';

            EXEC sys.sp_executesql @Sql;


            /*================================================
              Step 9: Drop Old Default Constraint
            ================================================*/

            SET @Sql =
                  N'IF EXISTS' + @CRLF
                + N'(' + @CRLF
                + N'    SELECT 1' + @CRLF
                + N'    FROM sys.default_constraints' + @CRLF
                + N'    WHERE name = '
                + N'''DF_MannerEstimations_RegisteredOrganicProducer'''
                + @CRLF
                + N'      AND parent_object_id = '
                + N'OBJECT_ID(''dbo.MannerEstimations'')'
                + @CRLF
                + N')' + @CRLF
                + N'BEGIN' + @CRLF
                + @AlterMannerEstimations
                + N'DROP CONSTRAINT '
                + N'DF_MannerEstimations_RegisteredOrganicProducer;'
                + @CRLF
                + N'END;';

            EXEC sys.sp_executesql @Sql;


            /*================================================
              Step 10: Drop Countries FK
            ================================================*/

            SET @Sql =
                  N'IF EXISTS' + @CRLF
                + N'(' + @CRLF
                + N'    SELECT 1' + @CRLF
                + N'    FROM sys.foreign_keys' + @CRLF
                + N'    WHERE name = '
                + N'''FK_MannerEstimations_Countries'''
                + @CRLF
                + N'      AND parent_object_id = '
                + N'OBJECT_ID(''dbo.MannerEstimations'')'
                + @CRLF
                + N')' + @CRLF
                + N'BEGIN' + @CRLF
                + @AlterMannerEstimations
                + N'DROP CONSTRAINT FK_MannerEstimations_Countries;'
                + @CRLF
                + N'END;';

            EXEC sys.sp_executesql @Sql;


            /*================================================
              Step 11: Drop Organisations FK
            ================================================*/

            SET @Sql =
                  N'IF EXISTS' + @CRLF
                + N'(' + @CRLF
                + N'    SELECT 1' + @CRLF
                + N'    FROM sys.foreign_keys' + @CRLF
                + N'    WHERE name = '
                + N'''FK_MannerEstimations_Organisations'''
                + @CRLF
                + N'      AND parent_object_id = '
                + N'OBJECT_ID(''dbo.MannerEstimations'')'
                + @CRLF
                + N')' + @CRLF
                + N'BEGIN' + @CRLF
                + @AlterMannerEstimations
                + N'DROP CONSTRAINT FK_MannerEstimations_Organisations;'
                + @CRLF
                + N'END;';

            EXEC sys.sp_executesql @Sql;


            /*================================================
              Step 12: Drop Old Unique Constraint
            ================================================*/

            SET @Sql =
                  N'IF EXISTS' + @CRLF
                + N'(' + @CRLF
                + N'    SELECT 1' + @CRLF
                + N'    FROM sys.key_constraints' + @CRLF
                + N'    WHERE name = '
                + N'''UQ_MannerEstimations_Name_OrganisationID'''
                + @CRLF
                + N'      AND parent_object_id = '
                + N'OBJECT_ID(''dbo.MannerEstimations'')'
                + @CRLF
                + N')' + @CRLF
                + N'BEGIN' + @CRLF
                + @AlterMannerEstimations
                + N'DROP CONSTRAINT '
                + N'UQ_MannerEstimations_Name_OrganisationID;'
                + @CRLF
                + N'END;';

            EXEC sys.sp_executesql @Sql;


            /*================================================
              Step 13: Drop Old Farm Columns
            ================================================*/

            SET @Sql =
                  @AlterMannerEstimations
                + N'DROP COLUMN' + @CRLF
                + @OrganisationIDColumn
                + @FarmNameColumn
                + @CountryIDColumn
                + @PostcodeColumn
                + @AverageAnuualRainfallColumn
                + N'    RegisteredOrganicProducer;';

            EXEC sys.sp_executesql @Sql;


            PRINT 'MannerFarms migration completed successfully.';

        END;

    END;


    /*====================================================
      Rollback when migration could not map records
    ====================================================*/

    IF @MigrationFailed = 1
    BEGIN

        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        PRINT 'Migration transaction rolled back.';

    END
    ELSE
    BEGIN

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;
        END;

        PRINT 'Main migration transaction committed.';

    END;

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    PRINT 'Migration failed.';
    PRINT ERROR_MESSAGE();

END CATCH;


/*====================================================*
  VERIFICATION / OLD DATABASE SUPPORT

  If:
      FarmID exists
  AND:
      MannerFarmID does not exist

  Then:
      FarmID -> MannerFarmID

  If MannerFarmID already exists:
      Nothing is changed.
*====================================================*/

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      Step 14: FarmID -> MannerFarmID
    ====================================================*/

    IF COL_LENGTH
    (
        @MannerEstimationsTableName,
        'FarmID'
    ) IS NOT NULL
    AND COL_LENGTH
    (
        @MannerEstimationsTableName,
        'MannerFarmID'
    ) IS NULL
    BEGIN

        EXEC sp_rename
            'dbo.MannerEstimations.FarmID',
            'MannerFarmID',
            'COLUMN';

        PRINT 'FarmID renamed to MannerFarmID.';

    END
    ELSE
    BEGIN

        PRINT 'FarmID rename skipped.';

    END;


    /*====================================================
      Step 15: Rename Old Unique Constraint
    ====================================================*/

    IF EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE name =
            'UQ_MannerEstimations_Name_FarmID'
        AND parent_object_id =
            OBJECT_ID(@MannerEstimationsTableName)
    )
    AND NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE name =
            'UQ_MannerEstimations_Name_MannerFarmID'
        AND parent_object_id =
            OBJECT_ID(@MannerEstimationsTableName)
    )
    BEGIN

        EXEC sp_rename
            'dbo.MannerEstimations.UQ_MannerEstimations_Name_FarmID',
            'UQ_MannerEstimations_Name_MannerFarmID',
            'OBJECT';

        PRINT 'Unique constraint renamed.';

    END;


    /*====================================================
      Step 16: Create Unique Constraint
      ONLY if MannerFarmID exists
    ====================================================*/

    IF COL_LENGTH
    (
        @MannerEstimationsTableName,
        'MannerFarmID'
    ) IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE name =
            'UQ_MannerEstimations_Name_MannerFarmID'
        AND parent_object_id =
            OBJECT_ID(@MannerEstimationsTableName)
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        ADD CONSTRAINT UQ_MannerEstimations_Name_MannerFarmID
        UNIQUE
        (
            [Name],
            MannerFarmID
        );

        PRINT 'Unique constraint created.';

    END
    ELSE
    BEGIN

        PRINT 'Unique constraint creation skipped.';

    END;


    /*====================================================
      Verification Commit
    ====================================================*/

    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
    END;

    PRINT 'Verification completed successfully.';

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    PRINT 'Verification failed.';
    PRINT ERROR_MESSAGE();

END CATCH;

GO

GO
GO -- do not remove this GO