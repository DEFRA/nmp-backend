
CREATE PROCEDURE dbo.spWarning_GetAllManuresByField
(
    @FieldID INT,
    @ApplicationDate DATE,
    @IsCurrentOrganicManure BIT,
    @IsCurrentFertiliser BIT,
    @ExcludeID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH CropCTE AS
    (
        SELECT c.ID AS CropID
        FROM Crops c
        WHERE c.FieldID = @FieldID
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
        -- Organic Manures
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
        INNER JOIN ManagementPeriodCTE mp
            ON mp.ManagementPeriodID = om.ManagementPeriodID
        WHERE om.ApplicationDate >= @ApplicationDate
          AND (
                @IsCurrentOrganicManure = 0
                OR om.ID <> @ExcludeID
              )

        UNION ALL

        -- Fertiliser Manures
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
        INNER JOIN ManagementPeriodCTE mp
            ON mp.ManagementPeriodID = fm.ManagementPeriodID
        WHERE fm.ApplicationDate >= @ApplicationDate
          AND (
                @IsCurrentFertiliser = 0
                OR fm.ID <> @ExcludeID
              )
    ) AS Combined
    ORDER BY Combined.ApplicationDate DESC;
END;