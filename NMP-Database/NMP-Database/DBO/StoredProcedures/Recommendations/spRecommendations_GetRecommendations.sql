CREATE PROCEDURE [dbo].[spRecommendations_GetRecommendations]
    @FieldID INT,
    @HarvestYear INT
AS
BEGIN
    SELECT
        [Recommendations].[ID],
        [Recommendations].[ManagementPeriodID],
        [Recommendations].[CropN],
        [Recommendations].[CropP2O5],
        [Recommendations].[CropK2O],
        [Recommendations].[CropMgO],
        [Recommendations].[CropSO3],
        [Recommendations].[CropNa2O],
        [Recommendations].[CropLime],
        [Recommendations].[ManureN],
        [Recommendations].[ManureP2O5],
        [Recommendations].[ManureK2O],
        [Recommendations].[ManureMgO],
        [Recommendations].[ManureSO3],
        [Recommendations].[ManureNa2O],
        [Recommendations].[ManureLime],
        [Recommendations].[FertilizerN],
        [Recommendations].[FertilizerP2O5],
        [Recommendations].[FertilizerK2O],
        [Recommendations].[FertilizerMgO],
        [Recommendations].[FertilizerSO3],
        [Recommendations].[FertilizerNa2O],
        [Recommendations].[FertilizerLime],
        [Recommendations].[PH],
        [Recommendations].[SNSIndex],
        [Recommendations].[PIndex],
        [Recommendations].[KIndex],
        [Recommendations].[MgIndex],
        [Recommendations].[SIndex],
        [Recommendations].[NaIndex],
        [Recommendations].[Comments],
        [Recommendations].[CreatedOn],
        [Recommendations].[CreatedByID],
        [Recommendations].[ModifiedOn],
        [Recommendations].[ModifiedByID],
        [Recommendations].[PreviousID]
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