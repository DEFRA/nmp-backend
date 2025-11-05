
CREATE PROCEDURE [dbo].[spFields_DeleteFields]
    @FieldID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables to track whether this procedure started the transaction
    DECLARE @IsLocalTransaction BIT = 0;

    -- Check if we're in a transaction already
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @IsLocalTransaction = 1;
    END

    BEGIN TRY
        -- Step 1: Temporary tables for related IDs
        DECLARE @CropIDs TABLE (ID INT);
        DECLARE @SoilAnalysesIDs TABLE (ID INT);
        DECLARE @PreviousGrassIDs TABLE (ID INT);
        DECLARE @PKBalanceIDs TABLE (ID INT);
        DECLARE @PreviousCroppingIDs TABLE (ID INT);
        DECLARE @WarningMessageIDs TABLE (ID INT);

        -- Step 2: Fetch related entity IDs
        INSERT INTO @CropIDs (ID)
        SELECT ID FROM Crops WHERE FieldID = @FieldID;

        INSERT INTO @SoilAnalysesIDs (ID)
        SELECT ID FROM SoilAnalyses WHERE FieldID = @FieldID;

        INSERT INTO @PreviousGrassIDs (ID)
        SELECT ID FROM PreviousGrasses WHERE FieldID = @FieldID;

        INSERT INTO @PKBalanceIDs (ID)
        SELECT ID FROM PKBalances WHERE FieldID = @FieldID;

        INSERT INTO @PreviousCroppingIDs (ID)
        SELECT ID FROM PreviousCroppings WHERE FieldID = @FieldID;

        -- 🔹 NEW: Fetch WarningMessages related to this Field
        INSERT INTO @WarningMessageIDs (ID)
        SELECT ID FROM WarningMessages WHERE FieldID = @FieldID;

        -- Step 3: Delete Crops
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

        -- Step 4: Delete SoilAnalyses
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

        -- Step 5: Delete PreviousGrasses
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

        -- Step 6: Delete PKBalances by FieldID
        IF EXISTS (SELECT 1 FROM @PKBalanceIDs)
        BEGIN
            EXEC spPKBalances_DeleteByFieldID @FieldID;
        END

        -- Step 7: Delete InprogressCalculations
        EXEC spInprogressCalculations_DeleteByFieldID @FieldID;

        -- Step 8: Delete PreviousCroppings
        IF EXISTS (SELECT 1 FROM @PreviousCroppingIDs)
        BEGIN
            DECLARE @PreviousCroppingID INT;
            DECLARE pc_cursor CURSOR FOR SELECT ID FROM @PreviousCroppingIDs;
            OPEN pc_cursor;
            FETCH NEXT FROM pc_cursor INTO @PreviousCroppingID;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC spPreviousCroppings_DeletePreviousCroppings @PreviousCroppingID;
                FETCH NEXT FROM pc_cursor INTO @PreviousCroppingID;
            END
            CLOSE pc_cursor;
            DEALLOCATE pc_cursor;
        END

        -- 🔹 Step 9: Delete WarningMessages (NEW SECTION)
        IF EXISTS (SELECT 1 FROM @WarningMessageIDs)
        BEGIN
            DECLARE @WarningMessageID INT;
            DECLARE wm_cursor CURSOR FOR SELECT ID FROM @WarningMessageIDs;
            OPEN wm_cursor;
            FETCH NEXT FROM wm_cursor INTO @WarningMessageID;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC spWarningMessages_DeleteWarningMessages @WarningMessageID;
                FETCH NEXT FROM wm_cursor INTO @WarningMessageID;
            END
            CLOSE wm_cursor;
            DEALLOCATE wm_cursor;
        END

        -- Step 10: Finally delete the Field record
        DELETE FROM Fields WHERE ID = @FieldID;

        -- Step 11: Commit if we started the transaction
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
END