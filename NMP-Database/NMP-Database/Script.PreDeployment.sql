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

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      Constants
    ====================================================*/

    DECLARE @MannerFarmsTableName SYSNAME =
        N'dbo.MannerFarms';

    DECLARE @MannerEstimationsTableName SYSNAME =
        N'dbo.MannerEstimations';

    DECLARE @CRLF NVARCHAR(2) =
        CHAR(13) + CHAR(10);

    DECLARE @MEAlterTable NVARCHAR(100) =
        N'ALTER TABLE dbo.MannerEstimations ';

    DECLARE @MEAlterTableLine NVARCHAR(100) =
        N'ALTER TABLE dbo.MannerEstimations';

    DECLARE @OrganisationIDColumn NVARCHAR(100) =
        N'    OrganisationID,' + @CRLF;

    DECLARE @FarmNameColumn NVARCHAR(100) =
        N'    FarmName,' + @CRLF;

    DECLARE @CountryIDColumn NVARCHAR(100) =
        N'    CountryID,' + @CRLF;

    DECLARE @PostcodeColumn NVARCHAR(100) =
        N'    Postcode,' + @CRLF;

    DECLARE @AverageAnuualRainfallColumn NVARCHAR(100) =
        N'    AverageAnuualRainfall,' + @CRLF;

    DECLARE @RegisteredOrganicProducerColumn NVARCHAR(100) =
        N'    RegisteredOrganicProducer;';


    /*====================================================
      Check if MannerFarms already exists

      If it exists:
      - Do NOTHING
      - Do not modify MannerEstimations
      - Do not add MannerFarmID
      - Do not drop old columns
    ====================================================*/

    IF OBJECT_ID(@MannerFarmsTableName, 'U') IS NOT NULL
    BEGIN

        PRINT 'MannerFarms table already exists.';
        PRINT 'Main migration skipped. No changes were made.';

    END
    ELSE
    BEGIN

        PRINT 'MannerFarms table does not exist.';
        PRINT 'Starting MannerFarms migration.';


        /*====================================================
          Dynamic SQL variable
        ====================================================*/

        DECLARE @SQL NVARCHAR(MAX);


        /*====================================================
          Step 1: Create MannerFarms
        ====================================================*/

        SET @SQL =
              N'CREATE TABLE dbo.MannerFarms (' + @CRLF
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


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 2: Copy Unique Farm Data
        ====================================================*/

        SET @SQL =
              N';WITH FarmCTE AS (' + @CRLF

            + N'    SELECT' + @CRLF
            + @OrganisationIDColumn
            + N'    FarmName,' + @CRLF
            + @CountryIDColumn
            + @PostcodeColumn
            + @AverageAnuualRainfallColumn
            + N'    RegisteredOrganicProducer,' + @CRLF
            + N'    CreatedOn,' + @CRLF
            + N'    CreatedByID,' + @CRLF

            + N'    ROW_NUMBER() OVER (' + @CRLF
            + N'        PARTITION BY OrganisationID, FarmName' + @CRLF
            + N'        ORDER BY ID' + @CRLF
            + N'    ) AS RowNum' + @CRLF

            + N'    FROM dbo.MannerEstimations' + @CRLF
            + N')' + @CRLF

            + N'INSERT INTO dbo.MannerFarms' + @CRLF
            + N'(' + @CRLF
            + N'    OrganisationID,' + @CRLF
            + N'    [Name],' + @CRLF
            + N'    CountryID,' + @CRLF
            + N'    Postcode,' + @CRLF
            + N'    AverageAnuualRainfall,' + @CRLF
            + N'    RegisteredOrganicProducer,' + @CRLF
            + N'    CreatedOn,' + @CRLF
            + N'    CreatedByID' + @CRLF
            + N')' + @CRLF

            + N'SELECT' + @CRLF
            + @OrganisationIDColumn
            + N'    FarmName,' + @CRLF
            + @CountryIDColumn
            + @PostcodeColumn
            + @AverageAnuualRainfallColumn
            + N'    RegisteredOrganicProducer,' + @CRLF
            + N'    CreatedOn,' + @CRLF
            + N'    CreatedByID' + @CRLF

            + N'FROM FarmCTE' + @CRLF
            + N'WHERE RowNum = 1;';


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 3: Add MannerFarmID
        ====================================================*/

        SET @SQL =
            @MEAlterTable +
            N'ADD MannerFarmID INT NULL;';

        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 4: Update MannerFarmID
        ====================================================*/

        SET @SQL =
              N'UPDATE ME' + @CRLF
            + N'SET MannerFarmID = MF.ID' + @CRLF
            + N'FROM dbo.MannerEstimations AS ME' + @CRLF
            + N'INNER JOIN dbo.MannerFarms AS MF' + @CRLF
            + N'    ON MF.OrganisationID = ME.OrganisationID' + @CRLF
            + N'   AND MF.[Name] = ME.FarmName;';


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 5: Check Unmapped Records
        ====================================================*/

        DECLARE @UnmappedCount INT = 0;


        SET @SQL =
              N'SELECT @Count = COUNT(*)' + @CRLF
            + N'FROM dbo.MannerEstimations' + @CRLF
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
            @MEAlterTable +
            N'ALTER COLUMN MannerFarmID INT NOT NULL;';

        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 7: Create Foreign Key
        ====================================================*/

        SET @SQL =
              @MEAlterTableLine + @CRLF
            + N'ADD CONSTRAINT FK_MannerEstimations_MannerFarms' + @CRLF
            + N'    FOREIGN KEY (MannerFarmID)' + @CRLF
            + N'    REFERENCES dbo.MannerFarms(ID);';


        EXEC sys.sp_executesql @SQL;


        /*====================================================
          Step 8: Create Unique Constraint
        ====================================================*/

        SET @SQL =
              @MEAlterTableLine + @CRLF
            + N'ADD CONSTRAINT UQ_MannerEstimations_Name_MannerFarmID' + @CRLF
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
                @MEAlterTable +
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
                @MEAlterTable +
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
                @MEAlterTable +
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
                @MEAlterTable +
                N'DROP CONSTRAINT UQ_MannerEstimations_Name_OrganisationID;';

            EXEC sys.sp_executesql @SQL;

        END;


        /*====================================================
          Step 13: Drop Old Farm Columns
        ====================================================*/

        SET @SQL =
              @MEAlterTableLine + @CRLF
            + N'DROP COLUMN' + @CRLF
            + @OrganisationIDColumn
            + @FarmNameColumn
            + @CountryIDColumn
            + @PostcodeColumn
            + @AverageAnuualRainfallColumn
            + @RegisteredOrganicProducerColumn;


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


/*====================================================*
  VERIFICATION
  FarmID -> MannerFarmID
*====================================================*/

--10-08-2026

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