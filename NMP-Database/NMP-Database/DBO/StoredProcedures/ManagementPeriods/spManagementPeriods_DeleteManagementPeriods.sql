CREATE PROCEDURE [dbo].[spManagementPeriods_DeleteManagementPeriods]
    @ManagementPeriodID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecommendationID INT;
    DECLARE @OrganicManureID INT;
    DECLARE @FertiliserManuresID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Fetch and delete Recommendations and related RecommendationComments
        DECLARE recommendation_cursor CURSOR FOR
        SELECT ID FROM Recommendations WHERE ManagementPeriodID = @ManagementPeriodID;

        OPEN recommendation_cursor;
        FETCH NEXT FROM recommendation_cursor INTO @RecommendationID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spRecommendations_DeleteRecommendations @RecommendationID;
            FETCH NEXT FROM recommendation_cursor INTO @RecommendationID;
        END;

        CLOSE recommendation_cursor;
        DEALLOCATE recommendation_cursor;

        -- Fetch and delete OrganicManures
        DECLARE organicmanure_cursor CURSOR FOR
        SELECT ID FROM OrganicManures WHERE ManagementPeriodID = @ManagementPeriodID;

        OPEN organicmanure_cursor;
        FETCH NEXT FROM organicmanure_cursor INTO @OrganicManureID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spOrganicManures_DeleteOrganicManures @OrganicManureID;
            FETCH NEXT FROM organicmanure_cursor INTO @OrganicManureID;
        END;

        CLOSE organicmanure_cursor;
        DEALLOCATE organicmanure_cursor;

        -- Fetch and delete FertiliserManures
        DECLARE fertilisermanures_cursor CURSOR FOR
        SELECT ID FROM FertiliserManures WHERE ManagementPeriodID = @ManagementPeriodID;

        OPEN fertilisermanures_cursor;
        FETCH NEXT FROM fertilisermanures_cursor INTO @FertiliserManuresID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spFertiliserManures_DeleteFertiliserManures @FertiliserManuresID;
            FETCH NEXT FROM fertilisermanures_cursor INTO @FertiliserManuresID;
        END;

        CLOSE fertilisermanures_cursor;
        DEALLOCATE fertilisermanures_cursor;

        -- Delete the ManagementPeriod
        DELETE FROM ManagementPeriods
        WHERE ID = @ManagementPeriodID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(MAX);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
