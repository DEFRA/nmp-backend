
CREATE PROCEDURE [dbo].[spMannerFarms_DeleteByIDs]
    @MannerFarmsIDs NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Store MannerFarms IDs
        DECLARE @MannerFarmIDs TABLE
        (
            ID INT PRIMARY KEY
        );

        INSERT INTO @MannerFarmIDs (ID)
        SELECT DISTINCT TRY_CAST(value AS INT)
        FROM STRING_SPLIT(@MannerFarmsIDs, ',')
        WHERE TRY_CAST(value AS INT) IS NOT NULL;


        -- Store related MannerEstimation IDs
        DECLARE @MannerEstimationIDs TABLE
        (
            ID INT PRIMARY KEY
        );

        INSERT INTO @MannerEstimationIDs (ID)
        SELECT DISTINCT ME.ID
        FROM MannerEstimations ME
        INNER JOIN @MannerFarmIDs MF
            ON ME.MannerFarmID = MF.ID;


        -- Delete MannerEstimationApplications first
        DELETE MEA
        FROM MannerEstimationApplications MEA
        INNER JOIN @MannerEstimationIDs ME
            ON MEA.MannerEstimationID = ME.ID;


        -- Delete MannerEstimation records
        DELETE ME
        FROM MannerEstimations ME
        INNER JOIN @MannerEstimationIDs MEI
            ON ME.ID = MEI.ID;


        -- Delete MannerFarms records
        DELETE MF
        FROM MannerFarms MF
        INNER JOIN @MannerFarmIDs MFI
            ON MF.ID = MFI.ID;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;