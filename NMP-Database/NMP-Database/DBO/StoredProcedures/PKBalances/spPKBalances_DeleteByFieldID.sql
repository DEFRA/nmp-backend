CREATE PROCEDURE [dbo].[spPKBalances_DeleteByFieldID]
    @FieldID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable to track if this procedure started the transaction
    DECLARE @IsLocalTransaction BIT = 0;

    -- Check if we are already in a transaction
    IF @@TRANCOUNT = 0
    BEGIN
        -- No active transaction, so we start our own transaction
        BEGIN TRANSACTION;
        SET @IsLocalTransaction = 1;
    END

    BEGIN TRY
        -- Delete PKBalances where FieldID matches the input
        DELETE FROM PKBalances WHERE FieldID = @FieldID;

        -- Commit the transaction if this procedure started it
        IF @IsLocalTransaction = 1
        BEGIN
            COMMIT TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        -- Rollback if there was an error
        IF @IsLocalTransaction = 1
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Capture the error details
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        -- Rethrow the error
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
