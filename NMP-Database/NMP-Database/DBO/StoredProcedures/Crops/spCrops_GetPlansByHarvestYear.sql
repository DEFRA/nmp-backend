CREATE PROCEDURE [dbo].[spCrops_GetPlansByHarvestYear]
    @farmId INT,
    @harvestYear INT
AS
BEGIN
    SELECT
        [Crops].[CropTypeID],
        [Fields].[ID] AS FieldID,
        MIN([Fields].[Name]) AS FieldName,
        CASE
            WHEN MAX([Crops].[ModifiedOn]) IS NULL THEN MAX([Crops].[CreatedOn])
            ELSE MAX([Crops].[ModifiedOn])
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
    GROUP BY 
        [Crops].[CropTypeID],
        [Fields].[ID]
END