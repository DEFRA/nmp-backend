CREATE TABLE [dbo].[Users]
(
	[ID] INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    [GivenName] NVARCHAR(50) NOT NULL, 
    [Surname] NVARCHAR(50) NULL, 
    [Email] NVARCHAR(256) NOT NULL, 
    [UserIdentifier] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [UC_Users_UserIdentifier] UNIQUE ([UserIdentifier])
)
