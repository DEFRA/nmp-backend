CREATE PROCEDURE [dbo].[spWarning_GetAllManuresByManagementPeriod]
    @ManagementPeriodID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM (
        ---------------------------------------------------------
        -- ORGANIC MANURE
        ---------------------------------------------------------
        SELECT 
            om.ID,
            om.ManagementPeriodID,
            om.ApplicationDate,
            om.N,
            om.ApplicationRate,
            'Organic' AS ManureSource,
            CAST(0 AS BIT) AS isFertiliserManure,
            CAST(1 AS BIT) AS isOrganicManure
        FROM OrganicManures om
        WHERE om.ManagementPeriodID = @ManagementPeriodID

        UNION ALL

        ---------------------------------------------------------
        -- FERTILISER MANURE
        ---------------------------------------------------------
        SELECT
            fm.ID,
            fm.ManagementPeriodID,
            fm.ApplicationDate,
            fm.N,
            fm.ApplicationRate,
            'Fertiliser' AS ManureSource,
            CAST(1 AS BIT) AS isFertiliserManure,
            CAST(0 AS BIT) AS isOrganicManure
        FROM FertiliserManures fm
        WHERE fm.ManagementPeriodID = @ManagementPeriodID
    ) AS combined
    ORDER BY combined.ApplicationDate DESC;

END;