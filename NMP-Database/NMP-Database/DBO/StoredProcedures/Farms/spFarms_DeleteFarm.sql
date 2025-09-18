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
        DECLARE @NutrientsLoadingFarmDetailIDs TABLE (ID INT);
        DECLARE @NutrientsLoadingManuresIDs TABLE (ID INT);
        DECLARE @NutrientsLoadingLiveStocksIDs TABLE (ID INT);
        DECLARE @StoreCapacityIDs TABLE (ID INT);

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

        -- Fetch and store NutrientsLoadingFarmDetail IDs
        INSERT INTO @NutrientsLoadingFarmDetailIDs (ID)
        SELECT ID FROM NutrientsLoadingFarmDetails WHERE FarmID = @FarmID;

        -- Fetch and store NutrientsLoadingManures IDs
        INSERT INTO @NutrientsLoadingManuresIDs (ID)
        SELECT ID FROM NutrientsLoadingManures WHERE FarmID = @FarmID;

        -- Fetch and store NutrientsLoadingLiveStocks IDs
        INSERT INTO @NutrientsLoadingLiveStocksIDs (ID)
        SELECT ID FROM NutrientsLoadingLiveStocks WHERE FarmID = @FarmID;

        -- Fetch and store StoreCapacity IDs
        INSERT INTO @StoreCapacityIDs (ID)
        SELECT ID FROM StoreCapacities WHERE FarmID = @FarmID;

        -- Delete related RecommendationComments
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

        -- Delete related Recommendations
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

        -- Delete related OrganicManures
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

        -- Delete related SoilAnalyses
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

        -- Delete related FarmManureTypes
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

        -- Delete related ManagementPeriods
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

        -- Delete related Crops
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

        -- Delete related Fields
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

        -- Delete related ExcessRainfalls
        IF EXISTS (SELECT 1 FROM ExcessRainfalls WHERE FarmID = @FarmID)
        BEGIN
            DELETE FROM ExcessRainfalls WHERE FarmID = @FarmID;
        END

        -- Delete related NutrientsLoadingFarmDetails
        DECLARE @NutrientsLoadingFarmDetailID INT;
        DECLARE nutrientsLoadingFarmDetail_cursor CURSOR FOR SELECT ID FROM @NutrientsLoadingFarmDetailIDs;
        OPEN nutrientsLoadingFarmDetail_cursor;
        FETCH NEXT FROM nutrientsLoadingFarmDetail_cursor INTO @NutrientsLoadingFarmDetailID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spNutrientsLoadingFarmDetails_DeleteNutrientsLoadingFarmDetails @NutrientsLoadingFarmDetailID;
            FETCH NEXT FROM nutrientsLoadingFarmDetail_cursor INTO @NutrientsLoadingFarmDetailID;
        END
        CLOSE nutrientsLoadingFarmDetail_cursor;
        DEALLOCATE nutrientsLoadingFarmDetail_cursor;

        -- Delete related NutrientsLoadingManures
        DECLARE @NutrientsLoadingManuresID INT;
        DECLARE nutrientsLoadingManures_cursor CURSOR FOR SELECT ID FROM @NutrientsLoadingManuresIDs;
        OPEN nutrientsLoadingManures_cursor;
        FETCH NEXT FROM nutrientsLoadingManures_cursor INTO @NutrientsLoadingManuresID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spNutrientsLoadingManures_DeleteNutrientsLoadingManures @NutrientsLoadingManuresID;
            FETCH NEXT FROM nutrientsLoadingManures_cursor INTO @NutrientsLoadingManuresID;
        END
        CLOSE nutrientsLoadingManures_cursor;
        DEALLOCATE nutrientsLoadingManures_cursor;

        -- Delete related NutrientsLoadingLiveStocks
        DECLARE @NutrientsLoadingLiveStockID INT;
        DECLARE nutrientsLoadingLivestocks_cursor CURSOR FOR SELECT ID FROM @NutrientsLoadingLiveStocksIDs;
        OPEN nutrientsLoadingLivestocks_cursor;
        FETCH NEXT FROM nutrientsLoadingLivestocks_cursor INTO @NutrientsLoadingLiveStockID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spNutrientsLoadingLiveStocks_DeleteNutrientsLoadingLiveStocks @NutrientsLoadingLiveStockID;
            FETCH NEXT FROM nutrientsLoadingLivestocks_cursor INTO @NutrientsLoadingLiveStockID;
        END
        CLOSE nutrientsLoadingLivestocks_cursor;
        DEALLOCATE nutrientsLoadingLivestocks_cursor;

        -- Delete related StoreCapacities
        DECLARE @StoreCapacityID INT;
        DECLARE sc_cursor CURSOR FOR SELECT ID FROM @StoreCapacityIDs;
        OPEN sc_cursor;
        FETCH NEXT FROM sc_cursor INTO @StoreCapacityID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spStoreCapacities_DeleteStoreCapacities @StoreCapacityID;
            FETCH NEXT FROM sc_cursor INTO @StoreCapacityID;
        END
        CLOSE sc_cursor;
        DEALLOCATE sc_cursor;

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
END
GO


