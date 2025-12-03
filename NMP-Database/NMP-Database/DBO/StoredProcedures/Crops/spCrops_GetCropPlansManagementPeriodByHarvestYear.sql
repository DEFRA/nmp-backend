CREATE PROCEDURE [dbo].[spCrops_GetCropPlansManagementPeriodByHarvestYear]
    @fieldIds NVARCHAR(MAX),
    @harvestYear INT,
    @cropGroupName NVARCHAR(120) = NULL,
    @cropOrder INT = NULL
AS
BEGIN
    IF @cropGroupName IS NOT NULL
    BEGIN
        SELECT DISTINCT
            [ManagementPeriods].[ID]
        FROM
            [ManagementPeriods]
        INNER JOIN
            [Crops] ON [Crops].[ID] = [ManagementPeriods].[CropID]
        WHERE
            [Crops].[Year] = @harvestYear
            AND [Crops].[FieldID] IN (SELECT value FROM STRING_SPLIT(@fieldIds, ','))
            AND [Crops].[CropGroupName] = @cropGroupName
            AND [Crops].[Confirm] = 0
            AND (@cropOrder IS NULL OR [Crops].[CropOrder] = @cropOrder)
    END
    ELSE
    BEGIN
        SELECT DISTINCT
            [ManagementPeriods].[ID]
        FROM
            [ManagementPeriods]
        INNER JOIN
            [Crops] ON [Crops].[ID] = [ManagementPeriods].[CropID]
        WHERE
            [Crops].[Year] = @harvestYear
            AND [Crops].[FieldID] IN (SELECT value FROM STRING_SPLIT(@fieldIds, ','))
            AND [Crops].[Confirm] = 0
            AND (@cropOrder IS NULL OR [Crops].[CropOrder] = @cropOrder)
    END
END