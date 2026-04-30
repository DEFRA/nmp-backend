CREATE PROCEDURE [dbo].[spWarning_GetAllManuresByFieldOnly]
(
    @FieldID INT
)
AS
BEGIN
    EXEC spWarning_GetAllManuresBase @FieldID = @FieldID;
END;