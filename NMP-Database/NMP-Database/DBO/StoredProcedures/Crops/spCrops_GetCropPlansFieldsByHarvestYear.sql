CREATE PROCEDURE [dbo].[spCrops_GetCropPlansFieldsByHarvestYear]
    @farmId INT,
    @harvestYear INT,
    @cropTypeId INT
AS
BEGIN
    SELECT
        [Fields].[ID],
        [Fields].[Name]
    FROM
        [Crops]
    INNER JOIN
        [Fields] ON [Fields].[ID] = [Crops].[FieldID]
    WHERE
        [Fields].[FarmID] = @farmId
    AND [Crops].[Year] = @harvestYear
    AND [Crops].[CropTypeID] = @cropTypeId
    AND [Crops].[Confirm] = 0
END