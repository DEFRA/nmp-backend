CREATE PROCEDURE [dbo].[spCrops_GetPlansByHarvestYear]
    @farmId INT,
    @harvestYear INT
AS
BEGIN
    SELECT
        [Crops].[CropTypeID],
        [Fields].[ID] AS FieldID,
        [Fields].[Name] AS FieldName,
        [Crops].[Variety] AS CropVariety,
        [Crops].[OtherCropName] AS OtherCropName,
        CASE
            WHEN [Crops].[ModifiedOn] >= [Crops].[CreatedOn] THEN [Crops].[ModifiedOn]
            ELSE [Crops].[CreatedOn]
        END AS LastModifiedOn
    FROM
        [Crops]
    INNER JOIN
        [Fields] ON [Fields].[ID] = [Crops].[FieldID]
    WHERE
        [Fields].[FarmID] = @farmId
    AND 
        [Crops].[Year] = @harvestYear
    AND 
        [Crops].[Confirm] = 0
END