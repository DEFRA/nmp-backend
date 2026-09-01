CREATE PROCEDURE dbo.spMannerEstimations_Delete
(
    @Ids NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        ;WITH IdList AS
        (
            SELECT TRY_CAST(value AS INT) AS ID
            FROM STRING_SPLIT(@Ids, ',')
            WHERE TRY_CAST(value AS INT) IS NOT NULL
        )

        DELETE mea
        FROM MannerEstimationApplications mea
        INNER JOIN IdList ids
            ON ids.ID = mea.MannerEstimationID;

        ;WITH IdList AS
        (
            SELECT TRY_CAST(value AS INT) AS ID
            FROM STRING_SPLIT(@Ids, ',')
            WHERE TRY_CAST(value AS INT) IS NOT NULL
        )

        DELETE me
        FROM MannerEstimations me
        INNER JOIN IdList ids
            ON ids.ID = me.ID;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;