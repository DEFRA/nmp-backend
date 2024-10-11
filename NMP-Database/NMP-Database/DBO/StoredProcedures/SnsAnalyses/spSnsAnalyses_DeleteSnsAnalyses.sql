CREATE PROCEDURE [dbo].[spSnsAnalyses_DeleteSnsAnalyses]
	@Id INT
AS
BEGIN
    -- Start a local transaction only if not already part of a parent transaction
    DECLARE @IsLocalTransaction BIT = 0;

    -- Check if there is an active transaction
    IF @@TRANCOUNT = 0
    BEGIN
        -- Start a new transaction if there's no active one
        BEGIN TRANSACTION;
        SET @IsLocalTransaction = 1;
    END

    BEGIN TRY
        -- Check if the record exists
        IF EXISTS (SELECT 1 FROM [dbo].[SnsAnalyses] WHERE [Id] = @Id)
        BEGIN
            -- Delete the record
            DELETE FROM [dbo].[SnsAnalyses]
            WHERE [Id] = @Id;

            -- Commit if it's a local transaction
            IF @IsLocalTransaction = 1
            BEGIN
                COMMIT TRANSACTION;
                PRINT 'Record deleted and local transaction committed successfully.';
            END
            ELSE
            BEGIN
                -- No commit for parent transactions, it will be handled by the parent
                PRINT 'Record deleted, waiting for parent transaction to commit.';
            END
        END
        ELSE
        BEGIN
            -- If no record is found, raise an error
            RAISERROR('No record found with the given Id.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        -- Handle any errors and determine if a rollback is necessary
        IF XACT_STATE() = -1
        BEGIN
            -- If the transaction is uncommittable, rollback the whole transaction (including parent)
            ROLLBACK TRANSACTION;
            PRINT 'Transaction rolled back due to an error: ' + ERROR_MESSAGE();
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            -- If the transaction is still active, rollback the transaction
            IF @IsLocalTransaction = 1
            BEGIN
                ROLLBACK TRANSACTION;
                PRINT 'Local transaction rolled back due to an error: ' + ERROR_MESSAGE();
            END
            ELSE
            BEGIN
                -- If it's part of a parent transaction, just raise an error to trigger rollback at the parent level
                PRINT 'Error occurred in a parent transaction, rolling back.';
                THROW;
            END
        END
    END CATCH
END
GO
