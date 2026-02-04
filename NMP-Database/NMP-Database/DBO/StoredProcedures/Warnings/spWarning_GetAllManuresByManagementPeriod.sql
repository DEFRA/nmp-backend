
CREATE PROCEDURE dbo.spWarning_GetAllManuresByManagementPeriod
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

    -- Get all ManagementPeriods for the Field
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
        INNER JOIN ManagementPeriods mp 
            ON mp.ID = om.ManagementPeriodID
        INNER JOIN Crops c 
            ON c.ID = mp.CropID
        WHERE c.FieldID = @FieldID
          AND om.ApplicationDate >= @ApplicationDate
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
        INNER JOIN ManagementPeriods mp 
            ON mp.ID = fm.ManagementPeriodID
        INNER JOIN Crops c 
            ON c.ID = mp.CropID
        WHERE c.FieldID = @FieldID
          AND fm.ApplicationDate >= @ApplicationDate
          AND (
                @IsCurrentFertiliser = 0
                OR fm.ID <> @ExcludeID
              )
    ) AS Combined
    ORDER BY Combined.ApplicationDate DESC;
END;