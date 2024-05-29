CREATE PROCEDURE [dbo].[spUsers_MergeUser]
(
    @userIdentifier UNIQUEIDENTIFIER,
    @givenName NVARCHAR(50),
    @surname NVARCHAR(50),
    @email NVARCHAR(256)
)
AS
BEGIN
MERGE INTO Users AS target
USING (VALUES (@userIdentifier, @givenName, @surname, @email)) AS source (userIdentifier, givenName, surname, email)
ON target.UserIdentifier = source.userIdentifier
WHEN MATCHED THEN
    UPDATE SET GivenName = source.givenName, Surname = source.surname, Email = source.email
WHEN NOT MATCHED THEN
    INSERT (UserIdentifier, GivenName, Surname, Email) VALUES (source.userIdentifier, source.givenName, source.surname, source.email);
END