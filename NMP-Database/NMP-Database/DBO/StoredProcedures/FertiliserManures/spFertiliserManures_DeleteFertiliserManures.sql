CREATE PROCEDURE [dbo].[spFertiliserManures_DeleteFertiliserManures]
	@ID INT
AS
BEGIN
    -- Start a transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Delete from the FertiliserManures table where ID matches
        DELETE FROM [dbo].[FertiliserManures]
        WHERE [ID] = @ID;

        -- Commit the transaction if everything is successful
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If an error occurs, rollback the transaction
        ROLLBACK TRANSACTION;

        -- Raise the error so that it can be handled by the calling process
        THROW;
    END CATCH
END
GO


