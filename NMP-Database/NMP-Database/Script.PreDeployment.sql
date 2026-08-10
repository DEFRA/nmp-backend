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

/*====================================================
  MAIN MIGRATION
====================================================*/
BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      Check if MannerFarms already exists

      If it exists:
      - Do NOTHING
      - Do not add MannerFarmID
      - Do not modify MannerEstimations
      - Do not drop any columns
    ====================================================*/

    IF EXISTS
    (
        SELECT 1
        FROM sys.tables
        WHERE name = 'MannerFarms'
          AND schema_id = SCHEMA_ID('dbo')
    )
    BEGIN

        PRINT 'MannerFarms table already exists.';
        PRINT 'Migration skipped. No changes were made.';

        COMMIT TRANSACTION;
        RETURN;

    END;


    /*====================================================
      Step 1: Create MannerFarms Table
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

      Dynamic SQL is required because MannerFarmID
      was added immediately before this statement.
    ====================================================*/

    EXEC
    (
        N'
        UPDATE ME
        SET MannerFarmID = MF.ID

        FROM dbo.MannerEstimations AS ME

        INNER JOIN dbo.MannerFarms AS MF
            ON MF.OrganisationID = ME.OrganisationID
           AND MF.[Name] = ME.FarmName;
        '
    );


    /*====================================================
      Step 5: Check Unmapped Records
    ====================================================*/

    DECLARE @UnmappedCount INT;

    SET @UnmappedCount = 0;

    EXEC sys.sp_executesql
        N'
        SELECT @Count = COUNT(*)
        FROM dbo.MannerEstimations
        WHERE MannerFarmID IS NULL;
        ',
        N'@Count INT OUTPUT',
        @Count = @UnmappedCount OUTPUT;


    IF @UnmappedCount > 0
    BEGIN

        PRINT 'Migration failed: Some records could not be mapped to MannerFarms.';

        PRINT 'Unmapped records: '
              + CAST(@UnmappedCount AS VARCHAR(20));

        ROLLBACK TRANSACTION;

        RETURN;

    END;


    /*====================================================
      Step 6: Make MannerFarmID NOT NULL
    ====================================================*/

    EXEC
    (
        N'
        ALTER TABLE dbo.MannerEstimations
        ALTER COLUMN MannerFarmID INT NOT NULL;
        '
    );


    /*====================================================
      Step 7: Create Foreign Key
    ====================================================*/

    EXEC
    (
        N'
        ALTER TABLE dbo.MannerEstimations
        ADD CONSTRAINT FK_MannerEstimations_MannerFarms
            FOREIGN KEY (MannerFarmID)
            REFERENCES dbo.MannerFarms(ID);
        '
    );


    /*====================================================
      Step 8: Create Unique Constraint
    ====================================================*/

    EXEC
    (
        N'
        ALTER TABLE dbo.MannerEstimations
        ADD CONSTRAINT UQ_MannerEstimations_Name_MannerFarmID
            UNIQUE
            (
                [Name],
                [MannerFarmID]
            );
        '
    );


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
              OBJECT_ID('dbo.MannerEstimations')
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        DROP CONSTRAINT
            DF_MannerEstimations_RegisteredOrganicProducer;

    END;


    /*====================================================
      Step 10: Drop Old Countries Foreign Key
    ====================================================*/

    IF EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_MannerEstimations_Countries'
          AND parent_object_id =
              OBJECT_ID('dbo.MannerEstimations')
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        DROP CONSTRAINT
            FK_MannerEstimations_Countries;

    END;


    /*====================================================
      Step 11: Drop Old Organisations Foreign Key
    ====================================================*/

    IF EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_MannerEstimations_Organisations'
          AND parent_object_id =
              OBJECT_ID('dbo.MannerEstimations')
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
            'UQ_MannerEstimations_Name_OrganisationID'
          AND parent_object_id =
              OBJECT_ID('dbo.MannerEstimations')
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


    PRINT 'MannerFarms migration completed successfully.';


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

/*====================================================
  VERIFICATION / FINAL COLUMN RENAME
====================================================*/

BEGIN TRY

    BEGIN TRANSACTION;


    /*====================================================
      Step 10: Rename FarmID -> MannerFarmID
    ====================================================*/

    IF COL_LENGTH('dbo.MannerEstimations', 'FarmID') IS NOT NULL
       AND COL_LENGTH('dbo.MannerEstimations', 'MannerFarmID') IS NULL
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
      Step 11: Rename / Create Unique Constraint
    ====================================================*/

    IF EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE name = 'UQ_MannerEstimations_Name_FarmID'
          AND parent_object_id =
              OBJECT_ID('dbo.MannerEstimations')
    )
    BEGIN

        EXEC sp_rename
            'dbo.MannerEstimations.UQ_MannerEstimations_Name_FarmID',
            'UQ_MannerEstimations_Name_MannerFarmID',
            'OBJECT';

        PRINT 'Unique constraint renamed.';

    END
    ELSE IF NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE name = 'UQ_MannerEstimations_Name_MannerFarmID'
          AND parent_object_id =
              OBJECT_ID('dbo.MannerEstimations')
    )
    BEGIN

        ALTER TABLE dbo.MannerEstimations
        ADD CONSTRAINT UQ_MannerEstimations_Name_MannerFarmID
        UNIQUE
        (
            [Name],
            [MannerFarmID]
        );

        PRINT 'New unique constraint created.';

    END
    ELSE
    BEGIN

        PRINT 'Unique constraint already exists.';

    END;


    COMMIT TRANSACTION;

    PRINT 'Verification completed successfully.';

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();

    THROW;

END CATCH;

GO

GO -- do not remove this GO