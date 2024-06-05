CREATE PROCEDURE [dbo].[spCrops_GetCropPlansCropTypesByHarvestYear]
    @farmId INT,
    @harvestYear INT
AS
BEGIN
    SELECT
        [Crops].[CropTypeID]
    FROM
        [Crops]
    INNER JOIN
        [Fields] ON [Fields].[ID] = [Crops].[FieldID]
    WHERE
        [Fields].[FarmID] = @farmId
    AND [Crops].[Year] = @harvestYear
    AND [Crops].[Confirm] = 0
    GROUP BY
        [Crops].[CropTypeID]
END