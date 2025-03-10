CREATE PROCEDURE [dbo].[spFields_DeleteFields]
    @FieldID INT
AS
BEGIN
    SET NOCOUNT ON;

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
        -- Step 1: Use temporary tables to store intermediate results if needed
        DECLARE @CropIDs TABLE (ID INT);
        DECLARE @SoilAnalysesIDs TABLE (ID INT);
        DECLARE @PreviousGrassIDs TABLE (ID INT);
        DECLARE @PKBalanceIDs TABLE (ID INT);

        -- Fetch and store Crop IDs associated with the Field
        INSERT INTO @CropIDs (ID)
        SELECT ID FROM Crops WHERE FieldID = @FieldID;

        -- Fetch and store SoilAnalysis IDs associated with the Field
        INSERT INTO @SoilAnalysesIDs (ID)
        SELECT ID FROM SoilAnalyses WHERE FieldID = @FieldID;

        -- Fetch and store PreviousGrasses IDs associated with the Field
        INSERT INTO @PreviousGrassIDs (ID)
        SELECT ID FROM PreviousGrasses WHERE FieldID = @FieldID;

        -- Fetch and store PKBalance IDs associated with the Field
        INSERT INTO @PKBalanceIDs (ID)
        SELECT ID FROM PKBalances WHERE FieldID = @FieldID;

        -- Step 2: Delete each crop using the existing stored procedure
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

        -- Step 3: Delete SoilAnalysis records only if any exist
        IF EXISTS (SELECT 1 FROM @SoilAnalysesIDs)
        BEGIN
            DECLARE @SoilAnalysesID INT;
            DECLARE sa_cursor CURSOR FOR SELECT ID FROM @SoilAnalysesIDs;
            OPEN sa_cursor;
            FETCH NEXT FROM sa_cursor INTO @SoilAnalysesID;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC spSoilAnalyses_DeleteSoilAnalyses @SoilAnalysesID;
                FETCH NEXT FROM sa_cursor INTO @SoilAnalysesID;
            END
            CLOSE sa_cursor;
            DEALLOCATE sa_cursor;
        END

      
        -- Step 5: Delete PreviousGrasses records using the stored procedure
        IF EXISTS (SELECT 1 FROM @PreviousGrassIDs)
        BEGIN
            DECLARE @PreviousGrassID INT;
            DECLARE pg_cursor CURSOR FOR SELECT ID FROM @PreviousGrassIDs;
            OPEN pg_cursor;
            FETCH NEXT FROM pg_cursor INTO @PreviousGrassID;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC spPreviousGrasses_DeleteByID @PreviousGrassID;
                FETCH NEXT FROM pg_cursor INTO @PreviousGrassID;
            END
            CLOSE pg_cursor;
            DEALLOCATE pg_cursor;
        END

        -- Step 6: Delete PKBalances records only if any exist, using FieldID instead of PKBalanceID
        IF EXISTS (SELECT 1 FROM @PKBalanceIDs)
        BEGIN
            -- Call spPKBalances_DeleteByFieldID with @FieldID directly
            EXEC spPKBalances_DeleteByFieldID @FieldID;
        END

        -- Step 7: Just before deleting the Field, first delete from InprogressCalculations table using FieldID
        EXEC spInprogressCalculations_DeleteByFieldID @FieldID;

        -- Step 8: Now delete the Field
        DELETE FROM Fields WHERE ID = @FieldID;

        -- Step 9: Commit the transaction if this procedure started it
        IF @IsLocalTransaction = 1
        BEGIN
            COMMIT TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        -- Rollback if there was an error
        IF @IsLocalTransaction = 1
        BEGIN
            -- We started the transaction, so rollback
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