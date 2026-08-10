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

DECLARE @MannerEstimationsTableName SYSNAME = N'dbo.MannerEstimations';
DECLARE @MannerFarmsTableName SYSNAME = N'dbo.MannerFarms';


/*====================================================*
  MAIN MIGRATION
*====================================================*/

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      If MannerFarms already exists:
      DO NOTHING
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


        /*====================================================
          Entire old-column migration is Dynamic SQL.

          This prevents SQL Server from compiling old columns
          when this migration is not required.
        ====================================================*/

        EXEC sys.sp_executesql
        N'
        /*====================================================
          Step 1: Create MannerFarms
        ====================================================*/

        CREATE TABLE dbo.MannerFarms
        (
            ID INT IDENTITY(1,1) PRIMARY KEY,

            OrganisationID UNIQUEIDENTIFIER NOT NULL,

            [Name] NVARCHAR(250) NOT NULL,

            CountryID INT NOT NULL,

            Postcode NVARCHAR(50) NULL,

            AverageAnuualRainfall INT NULL,

            RegisteredOrganicProducer BIT NOT NULL
                CONSTRAINT DF_MannerFarms_RegisteredOrganicProducer
                DEFAULT (0),

            [CreatedOn] DATETIME2 NULL
                CONSTRAINT DF_MannerFarms_CreatedOn
                DEFAULT GETDATE(),

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

            CONSTRAINT FK_MannerFarms_Users_CreatedBy
                FOREIGN KEY ([CreatedByID])
                REFERENCES dbo.Users([ID]),

            CONSTRAINT FK_MannerFarms_Users_ModifiedBy
                FOREIGN KEY ([ModifiedByID])
                REFERENCES dbo.Users([ID])
        );


        /*====================================================
          Step 2: Copy Unique Farm Data
        ====================================================*/

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


        /*====================================================
          Step 3: Add MannerFarmID
        ====================================================*/

        ALTER TABLE dbo.MannerEstimations
        ADD MannerFarmID INT NULL;


        /*====================================================
          Step 4: Update MannerFarmID
        ====================================================*/

        UPDATE ME
        SET MannerFarmID = MF.ID

        FROM dbo.MannerEstimations AS ME

        INNER JOIN dbo.MannerFarms AS MF
            ON MF.OrganisationID = ME.OrganisationID
           AND MF.[Name] = ME.FarmName;


        /*====================================================
          Step 5: Check Unmapped Records
        ====================================================*/

        DECLARE @UnmappedCount INT;

        SELECT @UnmappedCount = COUNT(*)
        FROM dbo.MannerEstimations
        WHERE MannerFarmID IS NULL;


        IF @UnmappedCount > 0
        BEGIN

            PRINT ''Migration failed.'';

            PRINT ''Unmapped records: ''
                + CAST(@UnmappedCount AS VARCHAR(20));

            RETURN;

        END;


        /*====================================================
          Step 6: Make MannerFarmID NOT NULL
        ====================================================*/

        ALTER TABLE dbo.MannerEstimations
        ALTER COLUMN MannerFarmID INT NOT NULL;


        /*====================================================
          Step 7: Create Foreign Key
        ====================================================*/

        ALTER TABLE dbo.MannerEstimations
        ADD CONSTRAINT FK_MannerEstimations_MannerFarms
            FOREIGN KEY (MannerFarmID)
            REFERENCES dbo.MannerFarms(ID);


        /*====================================================
          Step 8: Create Unique Constraint
        ====================================================*/

        ALTER TABLE dbo.MannerEstimations
        ADD CONSTRAINT UQ_MannerEstimations_Name_MannerFarmID
            UNIQUE
            (
                [Name],
                MannerFarmID
            );


        /*====================================================
          Step 9: Drop Old Default Constraint
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.default_constraints
            WHERE name =
                ''DF_MannerEstimations_RegisteredOrganicProducer''
              AND parent_object_id =
                OBJECT_ID(''dbo.MannerEstimations'')
        )
        BEGIN

            ALTER TABLE dbo.MannerEstimations
            DROP CONSTRAINT
                DF_MannerEstimations_RegisteredOrganicProducer;

        END;


        /*====================================================
          Step 10: Drop Countries FK
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = ''FK_MannerEstimations_Countries''
              AND parent_object_id =
                OBJECT_ID(''dbo.MannerEstimations'')
        )
        BEGIN

            ALTER TABLE dbo.MannerEstimations
            DROP CONSTRAINT
                FK_MannerEstimations_Countries;

        END;


        /*====================================================
          Step 11: Drop Organisations FK
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.foreign_keys
            WHERE name = ''FK_MannerEstimations_Organisations''
              AND parent_object_id =
                OBJECT_ID(''dbo.MannerEstimations'')
        )
        BEGIN

            ALTER TABLE dbo.MannerEstimations
            DROP CONSTRAINT
                FK_MannerEstimations_Organisations;

        END;


        /*====================================================
          Step 12: Drop Old Unique Constraint
        ====================================================*/

        IF EXISTS
        (
            SELECT 1
            FROM sys.key_constraints
            WHERE name =
                ''UQ_MannerEstimations_Name_OrganisationID''
              AND parent_object_id =
                OBJECT_ID(''dbo.MannerEstimations'')
        )
        BEGIN

            ALTER TABLE dbo.MannerEstimations
            DROP CONSTRAINT
                UQ_MannerEstimations_Name_OrganisationID;

        END;


        /*====================================================
          Step 13: Drop Old Farm Columns
        ====================================================*/

        ALTER TABLE dbo.MannerEstimations
        DROP COLUMN
            OrganisationID,
            FarmName,
            CountryID,
            Postcode,
            AverageAnuualRainfall,
            RegisteredOrganicProducer;


        PRINT ''MannerFarms migration completed successfully.'';

        ';

    END;


    /*====================================================
      Commit
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