﻿CREATE PROCEDURE [dbo].[spRecommendations_GetRecommendations]
    @fieldId INT,
    @harvestYear INT
AS
BEGIN
    SELECT
        [Crops].[ID] AS Crop_ID,
        [Crops].[FieldID] AS Crop_FieldID,
        [Crops].[Year] AS Crop_Year,
        [Crops].[CropTypeID] AS Crop_CropTypeID,
        [Crops].[Variety] AS Crop_Variety,
        [Crops].[OtherCropName] AS Crop_OtherCropName,
        [Crops].[CropInfo1] AS Crop_CropInfo1,
        [Crops].[CropInfo2] AS Crop_CropInfo2,
        [Crops].[SowingDate] AS Crop_SowingDate,
        [Crops].[Yield] AS Crop_Yield,
        [Crops].[Confirm] AS Crop_Confirm,
        [Crops].[PreviousGrass] AS Crop_PreviousGrass,
        [Crops].[Comments] AS Crop_Comments,
        [Crops].[Establishment] AS Crop_Establishment,
        [Crops].[LivestockType] AS Crop_LivestockType,
        [Crops].[MilkYield] AS Crop_MilkYield,
        [Crops].[ConcentrateUse] AS Crop_ConcentrateUse,
        [Crops].[StockingRate] AS Crop_StockingRate,
        [Crops].[DefoliationSequence] AS Crop_DefoliationSequence,
        [Crops].[GrazingIntensity] AS Crop_GrazingIntensity,
        [Crops].[CreatedOn] AS Crop_CreatedOn,
        [Crops].[CreatedByID] AS Crop_CreatedByID,
        [Crops].[ModifiedOn] AS Crop_ModifiedOn,
        [Crops].[ModifiedByID] AS Crop_ModifiedByID,
        [Crops].[PreviousID] AS Crop_PreviousID,
        [Recommendations].[ID] AS Recommendation_ID,
        [Recommendations].[ManagementPeriodID] AS Recommendation_ManagementPeriodID,
        [Recommendations].[CropN] AS Recommendation_CropN,
        [Recommendations].[CropP2O5] AS Recommendation_CropP2O5,
        [Recommendations].[CropK2O] AS Recommendation_CropK2O,
        [Recommendations].[CropMgO] AS Recommendation_CropMgO,
        [Recommendations].[CropSO3] AS Recommendation_CropSO3,
        [Recommendations].[CropNa2O] AS Recommendation_CropNa2O,
        [Recommendations].[CropLime] AS Recommendation_CropLime,
        [Recommendations].[ManureN] AS Recommendation_ManureN,
        [Recommendations].[ManureP2O5] AS Recommendation_ManureP2O5,
        [Recommendations].[ManureK2O] AS Recommendation_ManureK2O,
        [Recommendations].[ManureMgO] AS Recommendation_ManureMgO,
        [Recommendations].[ManureSO3] AS Recommendation_ManureSO3,
        [Recommendations].[ManureNa2O] AS Recommendation_ManureNa2O,
        [Recommendations].[ManureLime] AS Recommendation_ManureLime,
        [Recommendations].[FertilizerN] AS Recommendation_FertilizerN,
        [Recommendations].[FertilizerP2O5] AS Recommendation_FertilizerP2O5,
        [Recommendations].[FertilizerK2O] AS Recommendation_FertilizerK2O,
        [Recommendations].[FertilizerMgO] AS Recommendation_FertilizerMgO,
        [Recommendations].[FertilizerSO3] AS Recommendation_FertilizerSO3,
        [Recommendations].[FertilizerNa2O] AS Recommendation_FertilizerNa2O,
        [Recommendations].[FertilizerLime] AS Recommendation_FertilizerLime,
        [Recommendations].[PH] AS Recommendation_PH,
        [Recommendations].[SNSIndex] AS Recommendation_SNSIndex,
        [Recommendations].[PIndex] AS Recommendation_PIndex,
        [Recommendations].[KIndex] AS Recommendation_KIndex,
        [Recommendations].[MgIndex] AS Recommendation_MgIndex,
        [Recommendations].[SIndex] AS Recommendation_SIndex,
        [Recommendations].[NaIndex] AS Recommendation_NaIndex,
        [Recommendations].[Comments] AS Recommendation_Comments,
        [Recommendations].[CreatedOn] AS Recommendation_CreatedOn,
        [Recommendations].[CreatedByID] AS Recommendation_CreatedByID,
        [Recommendations].[ModifiedOn] AS Recommendation_ModifiedOn,
        [Recommendations].[ModifiedByID] AS Recommendation_ModifiedByID,
        [Recommendations].[PreviousID] AS Recommendation_PreviousID
    FROM 
        [Recommendations]
    INNER JOIN
        [ManagementPeriods] ON [Recommendations].[ManagementPeriodID] = [ManagementPeriods].[ID]
    INNER JOIN
        [Crops] ON [ManagementPeriods].[CropID] = [Crops].[ID]
    WHERE
        [Crops].[FieldID] = @FieldID
    AND
        [Crops].[Year] = @HarvestYear;
END