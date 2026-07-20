CREATE PROCEDURE dbo.spMannerEstimationApplications_Delete
(
    @MannerEstimationApplicationID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DELETE FROM MannerEstimationApplications
        WHERE ID = @MannerEstimationApplicationID;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;