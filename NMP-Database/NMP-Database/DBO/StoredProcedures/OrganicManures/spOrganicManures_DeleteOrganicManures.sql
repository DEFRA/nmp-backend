
CREATE PROCEDURE [dbo].[spOrganicManures_DeleteOrganicManures]
    @OrganicManureID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LocalTran BIT = 0;
    DECLARE @ManureTypeID INT;

    BEGIN TRY
        -- Start a transaction only if none exists
        IF @@TRANCOUNT = 0
        BEGIN
            SET @LocalTran = 1;
            BEGIN TRANSACTION;
        END

        -- Get the ManureTypeID from OrganicManures
        SELECT @ManureTypeID = ManureTypeID
        FROM OrganicManures
        WHERE ID = @OrganicManureID;

        -- Delete from FarmManureTypes if ManureTypeID exists
        IF @ManureTypeID IS NOT NULL
        BEGIN
            DELETE FROM FarmManureTypes
            WHERE ManureTypeID = @ManureTypeID;
        END

        -- Delete the OrganicManure row
        DELETE FROM OrganicManures
        WHERE ID = @OrganicManureID;

        -- Commit only if we started the transaction
        IF @LocalTran = 1 AND @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        -- Rollback only if we started the transaction
        IF @LocalTran = 1 AND @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Return the original error to the caller
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO