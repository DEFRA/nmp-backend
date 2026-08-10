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

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      Table Name Constants
    ====================================================*/

    DECLARE @MannerFarmsTableName SYSNAME =
        N'dbo.MannerFarms';

    DECLARE @MannerEstimationsTableName SYSNAME =
        N'dbo.MannerEstimations';


    /*====================================================
      Check if MannerFarms already exists

      If it exists:
      - Do NOTHING
      - Do not modify MannerEstimations
      - Do not add MannerFarmID
      - Do not drop any columns
    ====================================================*/

    IF OBJECT_ID(@MannerFarmsTableName, 'U') IS NOT NULL
    BEGIN

        PRINT 'MannerFarms table already exists.';
        PRINT 'Main migration skipped. No changes were made.';

    END
    ELSE
    BEGIN

        PRINT 'MannerFarms table does not exist.';
        PRINT 'Starting MannerFarms migration...';


        /*====================================================
          Dynamic SQL

          Old MannerEstimations columns are inside dynamic SQL
          so SQL Server does not compile them when migration
          is not required.

          CHAR(13) + CHAR(10) is used instead of multiline
          string literals to avoid Sonar code point 10 error.
        ====================================================*/

        DECLARE @SQL NVARCHAR(MAX);


        SET @SQL =
              N'CREATE TABLE dbo.MannerFarms (' + CHAR(13) + CHAR(10)

            + N'    ID INT IDENTITY(1,1) PRIMARY KEY,' + CHAR(13) + CHAR(10)

            + N'    OrganisationID UNIQUEIDENTIFIER NOT NULL,' + CHAR(13) + CHAR(10)

            + N'    [Name] NVARCHAR(250) NOT NULL,' + CHAR(13) + CHAR(10)

            + N'    CountryID INT NOT NULL,' + CHAR(13) + CHAR(10)

            + N'    Postcode NVARCHAR(50) NULL,' + CHAR(13) + CHAR(10)

            + N'    AverageAnuualRainfall INT NULL,' + CHAR(13) + CHAR(10)

            + N'    RegisteredOrganicProducer BIT NOT NULL' + CHAR(13) + CHAR(10)
            + N'        CONSTRAINT DF_MannerFarms_RegisteredOrganicProducer' + CHAR(13) + CHAR(10)
            + N'        DEFAULT (0),' + CHAR(13) + CHAR(10)

            + N'    [CreatedOn] DATETIME2 NULL' + CHAR(13) + CHAR(10)
            + N'        CONSTRAINT DF_MannerFarms_CreatedOn' + CHAR(13) + CHAR(10)
            + N'        DEFAULT GETDATE(),' + CHAR(13) + CHAR(10)

            + N'    [CreatedByID] INT NULL,' + CHAR(13) + CHAR(10)

            + N'    [ModifiedOn] DATETIME2 NULL,' + CHAR(13) + CHAR(10)

            + N'    [ModifiedByID] INT NULL,' + CHAR(13) + CHAR(10)

            + N'    CONSTRAINT FK_MannerFarms_Countries' + CHAR(13) + CHAR(10)
            + N'        FOREIGN KEY (CountryID)' + CHAR(13) + CHAR(10)
            + N'        REFERENCES dbo.Countries(ID),' + CHAR(13) + CHAR(10)

            + N'    CONSTRAINT FK_MannerFarms_Organisations' + CHAR(13) + CHAR(10)
            + N'        FOREIGN KEY (OrganisationID)' + CHAR(13) + CHAR(10)
            + N'        REFERENCES dbo.Organisations(ID),' + CHAR(13) + CHAR(10)

            + N'    CONSTRAINT UQ_MannerFarms_Name_OrganisationID' + CHAR(13) + CHAR(10)
            + N'        UNIQUE ([Name], [OrganisationID]),' + CHAR(13) + CHAR(10)

            + N'    CONSTRAINT FK_MannerFarms_Users_CreatedBy' + CHAR(13) + CHAR(10)
            + N'        FOREIGN KEY ([CreatedByID])' + CHAR(13) + CHAR(10)
            + N'        REFERENCES dbo.Users([ID]),' + CHAR(13) + CHAR(10)

            + N'    CONSTRAINT FK_MannerFarms_Users_ModifiedBy' + CHAR(13) + CHAR(10)
            + N'        FOREIGN KEY ([ModifiedByID])' + CHAR(13) + CHAR(10)
            + N'        REFERENCES dbo.Users([ID])' + CHAR(13) + CHAR(10)

            + N');';


        /*====================================================
          Step 1: Create MannerFarms
        ====================================================*/

        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 2: Copy Unique Farm Data
        ====================================================*/

        SET @SQL =
              N';WITH FarmCTE AS (' + CHAR(13) + CHAR(10)

            + N'    SELECT' + CHAR(13) + CHAR(10)
            + N'        OrganisationID,' + CHAR(13) + CHAR(10)
            + N'        FarmName,' + CHAR(13) + CHAR(10)
            + N'        CountryID,' + CHAR(13) + CHAR(10)
            + N'        Postcode,' + CHAR(13) + CHAR(10)
            + N'        AverageAnuualRainfall,' + CHAR(13) + CHAR(10)
            + N'        RegisteredOrganicProducer,' + CHAR(13) + CHAR(10)
            + N'        CreatedOn,' + CHAR(13) + CHAR(10)
            + N'        CreatedByID,' + CHAR(13) + CHAR(10)

            + N'        ROW_NUMBER() OVER (' + CHAR(13) + CHAR(10)
            + N'            PARTITION BY OrganisationID, FarmName' + CHAR(13) + CHAR(10)
            + N'            ORDER BY ID' + CHAR(13) + CHAR(10)
            + N'        ) AS RowNum' + CHAR(13) + CHAR(10)

            + N'    FROM dbo.MannerEstimations' + CHAR(13) + CHAR(10)

            + N')' + CHAR(13) + CHAR(10)

            + N'INSERT INTO dbo.MannerFarms' + CHAR(13) + CHAR(10)
            + N'(' + CHAR(13) + CHAR(10)
            + N'    OrganisationID,' + CHAR(13) + CHAR(10)
            + N'    [Name],' + CHAR(13) + CHAR(10)
            + N'    CountryID,' + CHAR(13) + CHAR(10)
            + N'    Postcode,' + CHAR(13) + CHAR(10)
            + N'    AverageAnuualRainfall,' + CHAR(13) + CHAR(10)
            + N'    RegisteredOrganicProducer,' + CHAR(13) + CHAR(10)
            + N'    CreatedOn,' + CHAR(13) + CHAR(10)
            + N'    CreatedByID' + CHAR(13) + CHAR(10)
            + N')' + CHAR(13) + CHAR(10)

            + N'SELECT' + CHAR(13) + CHAR(10)
            + N'    OrganisationID,' + CHAR(13) + CHAR(10)
            + N'    FarmName,' + CHAR(13) + CHAR(10)
            + N'    CountryID,' + CHAR(13) + CHAR(10)
            + N'    Postcode,' + CHAR(13) + CHAR(10)
            + N'    AverageAnuualRainfall,' + CHAR(13) + CHAR(10)
            + N'    RegisteredOrganicProducer,' + CHAR(13) + CHAR(10)
            + N'    CreatedOn,' + CHAR(13) + CHAR(10)
            + N'    CreatedByID' + CHAR(13) + CHAR(10)

            + N'FROM FarmCTE' + CHAR(13) + CHAR(10)
            + N'WHERE RowNum = 1;';


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 3: Add MannerFarmID
        ====================================================*/

        SET @SQL =
            N'ALTER TABLE dbo.MannerEstimations ' +
            N'ADD MannerFarmID INT NULL;';

        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 4: Update MannerFarmID
        ====================================================*/

        SET @SQL =
              N'UPDATE ME' + CHAR(13) + CHAR(10)
            + N'SET MannerFarmID = MF.ID' + CHAR(13) + CHAR(10)

            + N'FROM dbo.MannerEstimations AS ME' + CHAR(13) + CHAR(10)

            + N'INNER JOIN dbo.MannerFarms AS MF' + CHAR(13) + CHAR(10)
            + N'    ON MF.OrganisationID = ME.OrganisationID' + CHAR(13) + CHAR(10)
            + N'   AND MF.[Name] = ME.FarmName;';


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 5: Check Unmapped Records
        ====================================================*/

        DECLARE @UnmappedCount INT = 0;


        SET @SQL =
              N'SELECT @Count = COUNT(*)' + CHAR(13) + CHAR(10)
            + N'FROM dbo.MannerEstimations' + CHAR(13) + CHAR(10)
            + N'WHERE MannerFarmID IS NULL;';


        EXEC sys.sp_executesql
            @SQL,
            N'@Count INT OUTPUT',
            @Count = @UnmappedCount OUTPUT;


        IF @UnmappedCount > 0
        BEGIN

            PRINT 'Migration failed.';
            PRINT 'Unmapped records: '
                + CAST(@UnmappedCount AS VARCHAR(20));

            ROLLBACK TRANSACTION;

            RETURN;

        END;


        /*====================================================
          Step 6: Make MannerFarmID NOT NULL
        ====================================================*/

        SET @SQL =
            N'ALTER TABLE dbo.MannerEstimations ' +
            N'ALTER COLUMN MannerFarmID INT NOT NULL;';

        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 7: Create Foreign Key
        ====================================================*/

        SET @SQL =
              N'ALTER TABLE dbo.MannerEstimations' + CHAR(13) + CHAR(10)
            + N'ADD CONSTRAINT FK_MannerEstimations_MannerFarms' + CHAR(13) + CHAR(10)
            + N'    FOREIGN KEY (MannerFarmID)' + CHAR(13) + CHAR(10)
            + N'    REFERENCES dbo.MannerFarms(ID);';


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 8: Create Unique Constraint
        ====================================================*/

        SET @SQL =
              N'ALTER TABLE dbo.MannerEstimations' + CHAR(13) + CHAR(10)
            + N'ADD CONSTRAINT UQ_MannerEstimations_Name_MannerFarmID' + CHAR(13) + CHAR(10)
            + N'    UNIQUE ([Name], MannerFarmID);';


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 9: Drop Old Default Constraint
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.default_constraints
            WHERE name =
                'DF_MannerEstimations_RegisteredOrganicProducer'
              AND parent_object_id =
                OBJECT_ID(@MannerEstimationsTableName)
        )
        BEGIN

            SET @SQL =
                N'ALTER TABLE dbo.MannerEstimations ' +
                N'DROP CONSTRAINT DF_MannerEstimations_RegisteredOrganicProducer;';

            EXEC sys.sp_executesql @SQL;

        END;


        /*====================================================
          Step 10: Drop Countries FK
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name =
                'FK_MannerEstimations_Countries'
              AND parent_object_id =
                OBJECT_ID(@MannerEstimationsTableName)
        )
        BEGIN

            SET @SQL =
                N'ALTER TABLE dbo.MannerEstimations ' +
                N'DROP CONSTRAINT FK_MannerEstimations_Countries;';

            EXEC sys.sp_executesql @SQL;

        END;


        /*====================================================
          Step 11: Drop Organisations FK
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name =
                'FK_MannerEstimations_Organisations'
              AND parent_object_id =
                OBJECT_ID(@MannerEstimationsTableName)
        )
        BEGIN

            SET @SQL =
                N'ALTER TABLE dbo.MannerEstimations ' +
                N'DROP CONSTRAINT FK_MannerEstimations_Organisations;';

            EXEC sys.sp_executesql @SQL;

        END;


        /*====================================================
          Step 12: Drop Old Unique Constraint
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.key_constraints
            WHERE name =
                'UQ_MannerEstimations_Name_OrganisationID'
              AND parent_object_id =
                OBJECT_ID(@MannerEstimationsTableName)
        )
        BEGIN

            SET @SQL =
                N'ALTER TABLE dbo.MannerEstimations ' +
                N'DROP CONSTRAINT UQ_MannerEstimations_Name_OrganisationID;';

            EXEC sys.sp_executesql @SQL;

        END;


        /*====================================================
          Step 13: Drop Old Farm Columns
        ====================================================*/

        SET @SQL =
              N'ALTER TABLE dbo.MannerEstimations' + CHAR(13) + CHAR(10)
            + N'DROP COLUMN' + CHAR(13) + CHAR(10)
            + N'    OrganisationID,' + CHAR(13) + CHAR(10)
            + N'    FarmName,' + CHAR(13) + CHAR(10)
            + N'    CountryID,' + CHAR(13) + CHAR(10)
            + N'    Postcode,' + CHAR(13) + CHAR(10)
            + N'    AverageAnuualRainfall,' + CHAR(13) + CHAR(10)
            + N'    RegisteredOrganicProducer;';


        EXEC sys.sp_executesql @SQL;


        PRINT 'MannerFarms migration completed successfully.';

    END;


    /*====================================================
      Commit Transaction
    ====================================================*/

    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
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

GO


GO


/*====================================================*
  VERIFICATION
  FarmID -> MannerFarmID
*====================================================*/

DECLARE @MannerEstimationsTableName SYSNAME =
    N'dbo.MannerEstimations';

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      Step 14: Rename FarmID -> MannerFarmID

      Only if:
      FarmID exists
      AND
      MannerFarmID does not exist
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

        EXEC sys.sp_rename
            @objname = 'dbo.MannerEstimations.FarmID',
            @newname = 'MannerFarmID',
            @objtype = 'COLUMN';

        PRINT 'FarmID renamed to MannerFarmID.';

    END
    ELSE
    BEGIN

        PRINT 'FarmID rename skipped.';

    END;


    /*====================================================
      Step 15: Rename Existing Unique Constraint

      FarmID constraint
      ->
      MannerFarmID constraint
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

        EXEC sys.sp_rename
            @objname = 'dbo.MannerEstimations.UQ_MannerEstimations_Name_FarmID',
            @newname = 'UQ_MannerEstimations_Name_MannerFarmID',
            @objtype = 'OBJECT';

        PRINT 'Unique constraint renamed.';

    END;


    /*====================================================
      Step 16: Create Unique Constraint
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
      Commit Verification
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
GO -- do not remove this GO