CREATE PROCEDURE [dbo].[spWarning_GetAllManuresBase]
(
    @FarmID INT = NULL,
    @FieldID INT = NULL,
    @CropID INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ManagementPeriodCTE AS
    (
        SELECT mp.ID AS ManagementPeriodID
        FROM ManagementPeriods mp
        INNER JOIN Crops c ON c.ID = mp.CropID
        INNER JOIN Fields f ON f.ID = c.FieldID
        WHERE
            (@CropID IS NOT NULL AND mp.CropID = @CropID)
            OR (@CropID IS NULL AND @FieldID IS NOT NULL AND c.FieldID = @FieldID)
            OR (@CropID IS NULL AND @FieldID IS NULL AND @FarmID IS NOT NULL AND f.FarmID = @FarmID)
    )

    SELECT *
    FROM
    (
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