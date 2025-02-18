CREATE PROCEDURE [dbo].[spCrops_GetPlansByHarvestYear]
    @farmId INT,
    @harvestYear INT
AS
BEGIN
   SELECT
        [Crops].[ID] AS CropID,               -- Add this line to retrieve Crops.ID
        [Crops].[CropTypeID],
        [Fields].[ID] AS FieldID,
        [Fields].[Name] AS FieldName,
        [Crops].[Variety] AS CropVariety,
        [Crops].[OtherCropName] AS OtherCropName,
		[Crops].[CropInfo1] AS CropInfo1,
		[Crops].[Yield] AS Yield,
		[Crops].[CropGroupName] AS CropGroupName,
		[Crops].[Year] AS Year,
		[Crops].[CropOrder] AS CropOrder,
        CASE
            WHEN [Crops].[ModifiedOn] >= [Crops].[CreatedOn] THEN [Crops].[ModifiedOn]
            ELSE [Crops].[CreatedOn]
        END AS LastModifiedOn,
        (SELECT COUNT(DISTINCT [OrganicManures].[ID]) FROM [OrganicManures] WHERE [OrganicManures].[ManagementPeriodID] = [ManagementPeriods].[ID]) AS TotalOrganicManures,
        (SELECT COUNT(DISTINCT [FertiliserManures].[ID])  FROM [FertiliserManures]  WHERE [FertiliserManures].[ManagementPeriodID] = [ManagementPeriods].[ID]) AS TotalFertiliserManures
   FROM
        [Crops]
    INNER JOIN
        [Fields] ON [Fields].[ID] = [Crops].[FieldID]
    INNER JOIN
    	[ManagementPeriods] ON [ManagementPeriods].[CropID] = [Crops].[ID]
    WHERE
        [Fields].[FarmID] = @farmId
    AND 
        [Crops].[Year] = @harvestYear
    AND 
        [Crops].[Confirm] = 0
END