
CREATE   PROCEDURE [dbo].[spWarning_GetAllManuresByFarm]
(
    @FarmID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH FieldCTE AS
    (
        SELECT f.ID AS FieldID
        FROM Fields f
        WHERE f.FarmID = @FarmID
    ),
    CropCTE AS
    (
        SELECT c.ID AS CropID
        FROM Crops c
        INNER JOIN FieldCTE f
            ON f.FieldID = c.FieldID
    ),
    ManagementPeriodCTE AS
    (
        SELECT mp.ID AS ManagementPeriodID
        FROM ManagementPeriods mp
        INNER JOIN CropCTE c
            ON c.CropID = mp.CropID
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