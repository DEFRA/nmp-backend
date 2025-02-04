CREATE PROCEDURE [dbo].[spFarms_DeleteFarm]
    @FarmID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(MAX);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @FieldID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Use temporary tables to store intermediate results
        DECLARE @FieldIDs TABLE (ID INT);
        DECLARE @CropIDs TABLE (ID INT);
        DECLARE @ManagementPeriodIDs TABLE (ID INT);
        DECLARE @RecommendationIDs TABLE (ID INT);
        DECLARE @FarmManureTypeIDs TABLE (ID INT);
        DECLARE @SoilAnalysisIDs TABLE (ID INT);

        -- Fetch and store Field IDs
        INSERT INTO @FieldIDs (ID)
        SELECT ID FROM Fields WHERE FarmID = @FarmID;

        -- Fetch and store Crop IDs
        INSERT INTO @CropIDs (ID)
        SELECT ID FROM Crops WHERE FieldID IN (SELECT ID FROM @FieldIDs);

        -- Fetch and store ManagementPeriod IDs
        INSERT INTO @ManagementPeriodIDs (ID)
        SELECT ID FROM ManagementPeriods WHERE CropID IN (SELECT ID FROM @CropIDs);

        -- Fetch and store Recommendation IDs
        INSERT INTO @RecommendationIDs (ID)
        SELECT ID FROM Recommendations WHERE ManagementPeriodID IN (SELECT ID FROM @ManagementPeriodIDs);

        -- Fetch and store FarmManureType IDs
        INSERT INTO @FarmManureTypeIDs (ID)
        SELECT ID FROM FarmManureTypes WHERE FarmID = @FarmID;

        -- Fetch and store SoilAnalysis IDs
        INSERT INTO @SoilAnalysisIDs (ID)
        SELECT ID FROM SoilAnalyses WHERE FieldID IN (SELECT ID FROM @FieldIDs);

        -- Delete related RecommendationComments using existing SP
        DECLARE @RecommendationID INT;
        DECLARE rec_cursor CURSOR FOR SELECT ID FROM @RecommendationIDs;

        OPEN rec_cursor;
        FETCH NEXT FROM rec_cursor INTO @RecommendationID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spRecommendationComments_DeleteRecommendationComments @RecommendationID;
            FETCH NEXT FROM rec_cursor INTO @RecommendationID;
        END
        CLOSE rec_cursor;
        DEALLOCATE rec_cursor;

        -- Delete related Recommendations using existing SP
        DECLARE rec_cursor2 CURSOR FOR SELECT ID FROM @RecommendationIDs;
        OPEN rec_cursor2;
        FETCH NEXT FROM rec_cursor2 INTO @RecommendationID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spRecommendations_DeleteRecommendations @RecommendationID;
            FETCH NEXT FROM rec_cursor2 INTO @RecommendationID;
        END
        CLOSE rec_cursor2;
        DEALLOCATE rec_cursor2;

        -- Delete related OrganicManures using existing SP
        DECLARE @ManagementPeriodID INT;
        DECLARE mp_cursor CURSOR FOR SELECT ID FROM @ManagementPeriodIDs;
        OPEN mp_cursor;
        FETCH NEXT FROM mp_cursor INTO @ManagementPeriodID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spOrganicManures_DeleteOrganicManures @ManagementPeriodID;
            FETCH NEXT FROM mp_cursor INTO @ManagementPeriodID;
        END
        CLOSE mp_cursor;
        DEALLOCATE mp_cursor;

        -- Delete related SoilAnalyses using existing SP
        DECLARE @SoilAnalysisID INT;
        DECLARE sa_cursor CURSOR FOR SELECT ID FROM @SoilAnalysisIDs;
        OPEN sa_cursor;
        FETCH NEXT FROM sa_cursor INTO @SoilAnalysisID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spSoilAnalyses_DeleteSoilAnalyses @SoilAnalysisID;
            FETCH NEXT FROM sa_cursor INTO @SoilAnalysisID;
        END
        CLOSE sa_cursor;
        DEALLOCATE sa_cursor;

        -- Delete related FarmManureTypes using existing SP
        DECLARE @FarmManureTypeID INT;
        DECLARE fm_cursor CURSOR FOR SELECT ID FROM @FarmManureTypeIDs;
        OPEN fm_cursor;
        FETCH NEXT FROM fm_cursor INTO @FarmManureTypeID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spFarmManureTypes_DeleteFarmManureTypes @FarmManureTypeID;
            FETCH NEXT FROM fm_cursor INTO @FarmManureTypeID;
        END
        CLOSE fm_cursor;
        DEALLOCATE fm_cursor;

        -- Delete related ManagementPeriods using existing SP
        DECLARE mp_cursor2 CURSOR FOR SELECT ID FROM @ManagementPeriodIDs;
        OPEN mp_cursor2;
        FETCH NEXT FROM mp_cursor2 INTO @ManagementPeriodID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spManagementPeriods_DeleteManagementPeriods @ManagementPeriodID;
            FETCH NEXT FROM mp_cursor2 INTO @ManagementPeriodID;
        END
        CLOSE mp_cursor2;
        DEALLOCATE mp_cursor2;

        -- Delete related Crops using existing SP
        DECLARE @CropID INT;
        DECLARE crop_cursor CURSOR FOR SELECT ID FROM @CropIDs;
        OPEN crop_cursor;
        FETCH NEXT FROM crop_cursor INTO @CropID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spCrops_DeleteCrops @CropID;
            FETCH NEXT FROM crop_cursor INTO @CropID;
        END
        CLOSE crop_cursor;
        DEALLOCATE crop_cursor;

        -- Delete related Fields using existing SP
        DECLARE field_cursor CURSOR FOR SELECT ID FROM @FieldIDs;
        OPEN field_cursor;
        FETCH NEXT FROM field_cursor INTO @FieldID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spFields_DeleteFields @FieldID;
            FETCH NEXT FROM field_cursor INTO @FieldID;
        END
        CLOSE field_cursor;
        DEALLOCATE field_cursor;

        -- Check if records exist in ExcessRainfalls for the given FarmID
        IF EXISTS (SELECT 1 FROM ExcessRainfalls WHERE FarmID = @FarmID)
        BEGIN
            -- Delete related ExcessRainfalls if records are found
            DELETE FROM ExcessRainfalls WHERE FarmID = @FarmID;
        END

        -- Finally, delete the Farm itself
        DELETE FROM Farms WHERE ID = @FarmID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO