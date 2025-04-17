CREATE PROCEDURE [dbo].[spRecommendations_GetRecommendations]
    @fieldId INT,
    @harvestYear INT
AS
BEGIN
     -- Aggregating FertiliserManures table
         WITH SummedFertiliserManures AS (
             SELECT
                 [ManagementPeriodID],
                 SUM([N]) AS Total_N,
                 SUM([P2O5]) AS Total_P2O5,
                 SUM([K2O]) AS Total_K2O,
                 SUM([MgO]) AS Total_MgO,
                 SUM([SO3]) AS Total_SO3,
                 SUM([Na2O]) AS Total_Na2O,
                 SUM([Lime]) AS Total_Lime,
                 SUM([NH4N]) AS Total_NH4N,
                 SUM([NO3N]) AS Total_NO3N
             FROM [FertiliserManures]
             GROUP BY [ManagementPeriodID]
         )
     

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
		[Crops].[CropOrder] AS Crop_CropOrder,
        [Crops].[Confirm] AS Crop_Confirm,
        [Crops].[PreviousGrass] AS Crop_PreviousGrass,
        [Crops].[Comments] AS Crop_Comments,
        [Crops].[Establishment] AS Crop_Establishment,
        [Crops].[LivestockType] AS Crop_LivestockType,
        [Crops].[MilkYield] AS Crop_MilkYield,
        [Crops].[ConcentrateUse] AS Crop_ConcentrateUse,
        [Crops].[StockingRate] AS Crop_StockingRate,
        [Crops].[DefoliationSequenceID] AS Crop_DefoliationSequenceID,
        [Crops].[GrazingIntensity] AS Crop_GrazingIntensity,
        [Crops].[CreatedOn] AS Crop_CreatedOn,
        [Crops].[CreatedByID] AS Crop_CreatedByID,
        [Crops].[ModifiedOn] AS Crop_ModifiedOn,
        [Crops].[ModifiedByID] AS Crop_ModifiedByID,
        [Crops].[PreviousID] AS Crop_PreviousID,
        [ManagementPeriods].[ID] AS ManagementPeriod_ID,
        [ManagementPeriods].[CropID] AS ManagementPeriod_CropID,
        [ManagementPeriods].[Defoliation] AS ManagementPeriod_Defoliation,
        [ManagementPeriods].[Utilisation1ID] AS ManagementPeriod_Utilisation1ID,
        [ManagementPeriods].[Utilisation2ID] AS ManagementPeriod_Utilisation2ID,
        [ManagementPeriods].[Yield] AS ManagementPeriod_Yield,
        [ManagementPeriods].[PloughedDown] AS ManagementPeriod_PloughedDown,
        [ManagementPeriods].[CreatedOn] AS ManagementPeriod_CreatedOn,
        [ManagementPeriods].[CreatedByID] AS ManagementPeriod_CreatedByID,
        [ManagementPeriods].[ModifiedOn] AS ManagementPeriod_ModifiedOn,
        [ManagementPeriods].[ModifiedByID] AS ManagementPeriod_ModifiedByID,
        [ManagementPeriods].[PreviousID] AS ManagementPeriod_PreviousID,
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
        [Recommendations].[NIndex] AS Recommendation_NIndex,
        [Recommendations].[Comments] AS Recommendation_Comments,
        [Recommendations].[CreatedOn] AS Recommendation_CreatedOn,
        [Recommendations].[CreatedByID] AS Recommendation_CreatedByID,
        [Recommendations].[ModifiedOn] AS Recommendation_ModifiedOn,
        [Recommendations].[ModifiedByID] AS Recommendation_ModifiedByID,
        [Recommendations].[PreviousID] AS Recommendation_PreviousID,
        [SummedFertiliserManures].[Total_N] AS FertiliserManure_FertiliserAppliedN,
        [SummedFertiliserManures].[Total_P2O5] AS FertiliserManure_FertiliserAppliedP2O5,
        [SummedFertiliserManures].[Total_K2O] AS FertiliserManure_FertiliserAppliedK2O,
        [SummedFertiliserManures].[Total_MgO] AS FertiliserManure_FertiliserAppliedMgO,
        [SummedFertiliserManures].[Total_SO3] AS FertiliserManure_FertiliserAppliedSO3,
        [SummedFertiliserManures].[Total_Na2O] AS FertiliserManure_FertiliserAppliedNa2O,
        [SummedFertiliserManures].[Total_Lime] AS FertiliserManure_FertiliserAppliedLime,
        [SummedFertiliserManures].[Total_NH4N] AS FertiliserManure_FertiliserAppliedNH4N,
        [SummedFertiliserManures].[Total_NO3N] AS FertiliserManure_FertiliserAppliedNO3N
    FROM 
        [Recommendations]
    INNER JOIN
        [ManagementPeriods] ON [Recommendations].[ManagementPeriodID] = [ManagementPeriods].[ID]
    INNER JOIN
        [Crops] ON [ManagementPeriods].[CropID] = [Crops].[ID]
    LEFT JOIN
        SummedFertiliserManures ON [Recommendations].[ManagementPeriodID] = [SummedFertiliserManures].[ManagementPeriodID]
    WHERE
        [Crops].[FieldID] = @fieldId
    AND
        [Crops].[Year] = @harvestYear;
END