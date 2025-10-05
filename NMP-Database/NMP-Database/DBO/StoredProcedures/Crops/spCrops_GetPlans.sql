CREATE PROCEDURE [dbo].[spCrops_GetPlans]
    @farmId INT,
    @confirm INT
AS
BEGIN
    SELECT
        c.[Year],
        MAX(
            COALESCE(
                c.[ModifiedOn], c.[CreatedOn],
                fi.[ModifiedOn], fi.[CreatedOn],
                sa.[ModifiedOn], sa.[CreatedOn],
                f.[ModifiedOn], f.[CreatedOn],
                mp.[ModifiedOn], mp.[CreatedOn],
                om.[ModifiedOn], om.[CreatedOn],
                fm.[ModifiedOn], fm.[CreatedOn],
                r.[ModifiedOn], r.[CreatedOn]
            )
        ) AS [LastModifiedOn]
        --CASE
        --WHEN MAX(c.[ModifiedOn]) IS NULL THEN MAX(c.[CreatedOn])
        --ELSE MAX(c.[ModifiedOn])
        --END AS LastModifiedOn
    FROM
        [Crops] c
    INNER JOIN
        [Fields] fi ON fi.[ID] = c.[FieldID]
    INNER JOIN
        [SoilAnalyses] sa ON sa.[FieldID] = fi.[ID]
    INNER JOIN
        [Farms] f ON f.[ID] = fi.[FarmID]
    INNER JOIN
        [ManagementPeriods] mp ON mp.[CropID] = c.[ID]
    LEFT JOIN
        [OrganicManures] om ON om.[ManagementPeriodID] = mp.[ID]
    LEFT JOIN
        [FertiliserManures] fm ON fm.[ManagementPeriodID] = mp.[ID]
    LEFT JOIN
        [Recommendations] r ON r.[ManagementPeriodID] = mp.[ID]
    WHERE
        f.[ID] = @farmId
    AND c.[Confirm] = @confirm
    GROUP BY 
        c.[Year]
END