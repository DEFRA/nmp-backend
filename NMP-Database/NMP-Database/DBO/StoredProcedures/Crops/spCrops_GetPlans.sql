CREATE PROCEDURE [dbo].[spCrops_GetPlans]
    @farmId INT,
    @confirm INT
AS
BEGIN
    SELECT
        [Crops].[Year],
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
    AND [Crops].[Confirm] = @confirm
    GROUP BY 
        [Crops].[Year]
END