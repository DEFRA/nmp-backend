
CREATE   PROCEDURE [dbo].[spWarning_GetAllManuresByCrop]
(
    @CropID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ManagementPeriodCTE AS
    (
        SELECT mp.ID AS ManagementPeriodID
        FROM ManagementPeriods mp
        WHERE mp.CropID = @CropID
    )
    SELECT *
    FROM
    (
        /* -----------------------------
           Organic Manures
        ------------------------------*/
        SELECT 
            om.ID,
            om.ManagementPeriodID,
            om.ApplicationDate,
            om.N,
            om.ApplicationRate,
            'Organic' AS ManureSource,
            CAST(0 AS BIT) AS IsFertiliserManure,
            CAST(1 AS BIT) AS IsOrganicManure
        FROM OrganicManures om
        INNER JOIN ManagementPeriodCTE mp
            ON mp.ManagementPeriodID = om.ManagementPeriodID

        UNION ALL

        /* -----------------------------
           Fertiliser Manures
        ------------------------------*/
        SELECT
            fm.ID,
            fm.ManagementPeriodID,
            fm.ApplicationDate,
            fm.N,
            fm.ApplicationRate,
            'Fertiliser' AS ManureSource,
            CAST(1 AS BIT) AS IsFertiliserManure,
            CAST(0 AS BIT) AS IsOrganicManure
        FROM FertiliserManures fm
        INNER JOIN ManagementPeriodCTE mp
            ON mp.ManagementPeriodID = fm.ManagementPeriodID
    ) AS Combined
    ORDER BY Combined.ApplicationDate DESC;
END;