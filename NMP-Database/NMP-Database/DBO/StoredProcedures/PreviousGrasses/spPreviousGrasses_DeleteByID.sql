CREATE PROCEDURE [dbo].[spPreviousGrasses_DeleteByID]
	@PreviousGrassID INT
AS
	 -- Variables to track whether this procedure started the transaction
    DECLARE @IsLocalTransaction BIT = 0;

    -- Check if we're in a transaction already (i.e., this was called from another procedure)
    IF @@TRANCOUNT = 0
    BEGIN
        -- No active transaction, so we start our own transaction
        BEGIN TRANSACTION;
        SET @IsLocalTransaction = 1;
    END

    BEGIN TRY
        -- Delete the PreviousGrasses record by ID
        DELETE FROM PreviousGrasses WHERE ID = @PreviousGrassID;

        -- Commit the transaction if it was started here
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
RETURN 0
