CREATE PROCEDURE [dbo].[spWarning_GetAllManuresByCrop]
(
    @CropID INT
)
AS
BEGIN
    EXEC spWarning_GetAllManuresBase @CropID = @CropID;
END;