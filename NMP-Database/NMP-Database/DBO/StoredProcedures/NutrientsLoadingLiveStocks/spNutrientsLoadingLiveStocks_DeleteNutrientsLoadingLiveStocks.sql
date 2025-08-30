CREATE PROCEDURE [dbo].[spNutrientsLoadingLiveStocks_DeleteNutrientsLoadingLiveStocks]
    @NutrientsLoadingLiveStockID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete the specified NutrientsLoadingLiveStocks record
        DELETE FROM NutrientsLoadingLiveStocks WHERE ID = @NutrientsLoadingLiveStockID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(MAX);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;