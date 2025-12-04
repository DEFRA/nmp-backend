CREATE PROCEDURE [dbo].[spCrops_GetCropPlansFieldsByHarvestYear]
    @farmId INT,
    @harvestYear INT,
    @cropGroupName NVARCHAR(120) = NULL
AS
BEGIN
    IF @cropGroupName IS NOT NULL
    BEGIN
        SELECT DISTINCT
            [Fields].[ID],
            [Fields].[Name]
        FROM
            [Crops]
        INNER JOIN
            [Fields] ON [Fields].[ID] = [Crops].[FieldID]
        WHERE
            [Fields].[FarmID] = @farmId
        AND [Crops].[Year] = @harvestYear
        AND [Crops].[CropGroupName] = @cropGroupName
        AND [Crops].[Confirm] = 0
    END
    ELSE
    BEGIN
        SELECT DISTINCT
            [Fields].[ID],
            [Fields].[Name]
        FROM
            [Crops]
        INNER JOIN
            [Fields] ON [Fields].[ID] = [Crops].[FieldID]
        WHERE
            [Fields].[FarmID] = @farmId
        AND [Crops].[Year] = @harvestYear
        AND [Crops].[Confirm] = 0
    END
END