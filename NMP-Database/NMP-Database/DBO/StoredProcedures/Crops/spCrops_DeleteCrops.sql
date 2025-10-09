
CREATE PROCEDURE [dbo].[spCrops_DeleteCrops]
    @CropsID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ManagementPeriodID INT;
    DECLARE @RecommendationID INT;
    DECLARE @RecommendationCommentsID INT;
    DECLARE @OrganicManureID INT;    
    DECLARE @SnsAnalysisID INT;
    DECLARE @WarningMessageID INT;
    DECLARE @SnsAnalysesIDs TABLE (ID INT);

    BEGIN TRY
        BEGIN TRANSACTION;

        --------------------------------------------
        -- Step 1: Delete WarningMessages for Crop
        --------------------------------------------
        DECLARE cur_WarningMessages CURSOR FOR
        SELECT ID FROM [dbo].[WarningMessages] WHERE CropID = @CropsID;

        OPEN cur_WarningMessages;
        FETCH NEXT FROM cur_WarningMessages INTO @WarningMessageID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC [dbo].[spWarningMessages_DeleteWarningMessage] @WarningMessageID;
            FETCH NEXT FROM cur_WarningMessages INTO @WarningMessageID;
        END;

        CLOSE cur_WarningMessages;
        DEALLOCATE cur_WarningMessages;


        --------------------------------------------
        -- Step 2: Fetch ManagementPeriod IDs related to the Crop
        --------------------------------------------
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


        --------------------------------------------
        -- Step 3: Delete SNS Analyses linked to Crop
        --------------------------------------------
        INSERT INTO @SnsAnalysesIDs (ID)
        SELECT ID FROM SnsAnalyses WHERE CropID = @CropsID;

        IF EXISTS (SELECT 1 FROM @SnsAnalysesIDs)
        BEGIN
            DECLARE sns_cursor CURSOR FOR SELECT ID FROM @SnsAnalysesIDs;
            OPEN sns_cursor;
            FETCH NEXT FROM sns_cursor INTO @SnsAnalysisID;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC spSnsAnalyses_DeleteSnsAnalyses @SnsAnalysisID;
                FETCH NEXT FROM sns_cursor INTO @SnsAnalysisID;
            END
            CLOSE sns_cursor;
            DEALLOCATE sns_cursor;
        END


        --------------------------------------------
        -- Step 4: Delete Crop itself
        --------------------------------------------
        DELETE FROM [dbo].[Crops] WHERE [ID] = @CropsID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
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