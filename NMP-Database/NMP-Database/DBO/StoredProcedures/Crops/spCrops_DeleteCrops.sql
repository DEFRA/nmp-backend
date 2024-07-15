CREATE PROCEDURE [dbo].[spCrops_DeleteCrops]
    @CropsID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ManagementPeriodID INT;
    DECLARE @RecommendationID INT;
    DECLARE @RecommendationCommentsID INT;
    DECLARE @OrganicManureID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Fetch ManagementPeriod IDs related to the Crop
        DECLARE cur_ManagementPeriod CURSOR FOR
        SELECT ID FROM ManagementPeriods WHERE CropID = @CropsID;

        OPEN cur_ManagementPeriod;
        FETCH NEXT FROM cur_ManagementPeriod INTO @ManagementPeriodID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Fetch and delete OrganicManures related to the ManagementPeriod
            DECLARE cur_OrganicManure CURSOR FOR
            SELECT ID FROM OrganicManures WHERE ManagementPeriodID = @ManagementPeriodID;

            OPEN cur_OrganicManure;
            FETCH NEXT FROM cur_OrganicManure INTO @OrganicManureID;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC spOrganicManures_DeleteOrganicManures @OrganicManureID;
                FETCH NEXT FROM cur_OrganicManure INTO @OrganicManureID;
            END;

            CLOSE cur_OrganicManure;
            DEALLOCATE cur_OrganicManure;

            -- Fetch and delete Recommendations related to the ManagementPeriod
            DECLARE cur_Recommendation CURSOR FOR
            SELECT ID FROM Recommendations WHERE ManagementPeriodID = @ManagementPeriodID;

            OPEN cur_Recommendation;
            FETCH NEXT FROM cur_Recommendation INTO @RecommendationID;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Fetch and delete RecommendationComments related to the Recommendation
                DECLARE cur_RecommendationComments CURSOR FOR
                SELECT ID FROM RecommendationComments WHERE RecommendationID = @RecommendationID;

                OPEN cur_RecommendationComments;
                FETCH NEXT FROM cur_RecommendationComments INTO @RecommendationCommentsID;

                WHILE @@FETCH_STATUS = 0
                BEGIN
                    EXEC spRecommendationComments_DeleteRecommendationComments @RecommendationCommentsID;
                    FETCH NEXT FROM cur_RecommendationComments INTO @RecommendationCommentsID;
                END;

                CLOSE cur_RecommendationComments;
                DEALLOCATE cur_RecommendationComments;

                -- Delete the Recommendation
                EXEC spRecommendations_DeleteRecommendations @RecommendationID;
                FETCH NEXT FROM cur_Recommendation INTO @RecommendationID;
            END;

            CLOSE cur_Recommendation;
            DEALLOCATE cur_Recommendation;

            -- Delete the ManagementPeriod
            EXEC spManagementPeriods_DeleteManagementPeriods @ManagementPeriodID;
            FETCH NEXT FROM cur_ManagementPeriod INTO @ManagementPeriodID;
        END;

        CLOSE cur_ManagementPeriod;
        DEALLOCATE cur_ManagementPeriod;

        -- Delete the Crop
        DELETE FROM Crops WHERE ID = @CropsID;

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