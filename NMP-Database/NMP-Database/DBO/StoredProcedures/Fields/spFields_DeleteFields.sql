CREATE PROCEDURE [dbo].[spFields_DeleteFields]
    @FieldID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(MAX);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Use temporary tables to store intermediate results if needed
        DECLARE @CropIDs TABLE (ID INT);
        DECLARE @SoilAnalysisIDs TABLE (ID INT);

        -- Fetch and store Crop IDs associated with the Field
        INSERT INTO @CropIDs (ID)
        SELECT ID FROM Crops WHERE FieldID = @FieldID;

        -- Fetch and store SoilAnalysis IDs associated with the Field
        INSERT INTO @SoilAnalysisIDs (ID)
        SELECT ID FROM SoilAnalyses WHERE FieldID = @FieldID;

        -- Delete each crop using the existing stored procedure
        DECLARE @CropID INT;
        DECLARE crop_cursor CURSOR FOR SELECT ID FROM @CropIDs;
        OPEN crop_cursor;
        FETCH NEXT FROM crop_cursor INTO @CropID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spCrops_DeleteCrops @CropID;
            FETCH NEXT FROM crop_cursor INTO @CropID;
        END
        CLOSE crop_cursor;
        DEALLOCATE crop_cursor;

        -- Delete each SoilAnalysis record
        DECLARE @SoilAnalysisID INT;
        DECLARE sa_cursor CURSOR FOR SELECT ID FROM @SoilAnalysisIDs;
        OPEN sa_cursor;
        FETCH NEXT FROM sa_cursor INTO @SoilAnalysisID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC spSoilAnalyses_DeleteSoilAnalyses @SoilAnalysisID;
            FETCH NEXT FROM sa_cursor INTO @SoilAnalysisID;
        END
        CLOSE sa_cursor;
        DEALLOCATE sa_cursor;

        -- Now delete the Field
        DELETE FROM Fields WHERE ID = @FieldID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO