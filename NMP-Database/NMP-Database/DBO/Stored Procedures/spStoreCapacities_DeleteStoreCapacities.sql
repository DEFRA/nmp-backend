
CREATE   PROCEDURE [dbo].[spStoreCapacities_DeleteStoreCapacities]
    @ID INT   -- Always delete by ID
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Start transaction only if not already in a parent one
        IF @@TRANCOUNT = 0
            BEGIN TRANSACTION;

        DELETE FROM [dbo].[StoreCapacities]
        WHERE [ID] = @ID;

        -- Commit only if this procedure started the transaction
        IF XACT_STATE() = 1 AND @@TRANCOUNT = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback only if this procedure started the transaction
        IF XACT_STATE() <> 0 AND @@TRANCOUNT = 1
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END