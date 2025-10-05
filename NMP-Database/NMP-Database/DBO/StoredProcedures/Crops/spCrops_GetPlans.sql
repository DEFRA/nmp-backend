CREATE PROCEDURE [dbo].[spCrops_GetPlans]
    @farmId INT,
    @confirm INT
AS
BEGIN

SELECT
        t.[Year],
        ca.LastModifiedOn
    FROM
    (
        SELECT 
            c.[Year],
            MAX(COALESCE(c.ModifiedOn, c.CreatedOn))    AS mx_c,            
            MAX(COALESCE(mp.ModifiedOn, mp.CreatedOn))  AS mx_mp,
            MAX(COALESCE(om.ModifiedOn, om.CreatedOn))  AS mx_om,
            MAX(COALESCE(fm.ModifiedOn, fm.CreatedOn))  AS mx_fm,
			MAX(COALESCE(r.ModifiedOn, r.CreatedOn))  AS mx_r

        FROM Crops c
        INNER JOIN Fields f ON f.ID = c.FieldID
        INNER JOIN ManagementPeriods mp ON mp.CropID = c.ID
        LEFT JOIN OrganicManures om ON om.ManagementPeriodID = mp.ID
        LEFT JOIN FertiliserManures fm ON fm.ManagementPeriodID = mp.ID
		LEFT JOIN Recommendations r ON r.ManagementPeriodID = mp.ID
        WHERE f.FarmID = @farmId
          AND c.Confirm = @confirm
        GROUP BY c.[Year]
    ) t
    CROSS APPLY
    (
        SELECT MAX(v) AS LastModifiedOn
        FROM (VALUES (t.mx_c),(t.mx_mp),(t.mx_om),(t.mx_fm),(t.mx_r)) AS value(v)
    ) ca
    ORDER BY t.[Year];
END