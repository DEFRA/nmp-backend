CREATE PROCEDURE [dbo].[spOrganisations_MergeOrganisation]
(
    @organisationId UNIQUEIDENTIFIER,
    @organisationName NVARCHAR(512)
)
AS
BEGIN
MERGE INTO Organisations AS target
USING (VALUES (@organisationId, @organisationName)) AS source (organisationId, organisationName)
ON target.ID = source.organisationId
WHEN MATCHED THEN
    UPDATE SET Name = source.organisationName
WHEN NOT MATCHED THEN
    INSERT (ID, Name) VALUES (source.organisationId, source.organisationName);
END