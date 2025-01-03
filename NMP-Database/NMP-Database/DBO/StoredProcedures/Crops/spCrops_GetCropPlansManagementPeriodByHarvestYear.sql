﻿CREATE PROCEDURE [dbo].[spCrops_GetCropPlansManagementPeriodByHarvestYear]
    @fieldIds NVARCHAR(MAX),
    @harvestYear INT,
    @cropTypeId INT = NULL,
    @cropOrder INT = NULL
AS
BEGIN
    IF @cropTypeId IS NOT NULL
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
            AND [Crops].[CropTypeID] = @cropTypeId
            AND [Crops].[Confirm] = 0
            AND [Crops].[CropOrder] = @cropOrder
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
            AND [Crops].[CropOrder] = @cropOrder
    END
END