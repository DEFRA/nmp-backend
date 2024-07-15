CREATE PROCEDURE [dbo].[spOrganicManures_DeleteOrganicManures]
    @OrganicManureID INT
AS
BEGIN
    DELETE FROM OrganicManures
    WHERE ID = @OrganicManureID;
END;
GO