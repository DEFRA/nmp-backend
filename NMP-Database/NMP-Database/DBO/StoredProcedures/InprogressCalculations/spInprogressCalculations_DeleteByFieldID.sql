CREATE PROCEDURE [dbo].[spInprogressCalculations_DeleteByFieldID]
    @FieldID INT
AS
BEGIN
    -- Delete rows from InprogressCalculations where FieldID matches the input parameter
    DELETE FROM [dbo].[InprogressCalculations]
    WHERE [FieldID] = @FieldID;

    -- Check if any rows were affected (optional feedback)
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'No records found with the specified FieldID.';
    END
    ELSE
    BEGIN
        PRINT 'Records successfully deleted.';
    END
END
GO
