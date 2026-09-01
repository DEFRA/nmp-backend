CREATE PROCEDURE [dbo].[spWarning_GetAllManuresByFarm]
(
    @FarmID INT
)
AS
BEGIN
    EXEC spWarning_GetAllManuresBase @FarmID = @FarmID;
END;