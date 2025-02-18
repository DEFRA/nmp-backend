CREATE TABLE [dbo].[UserExtensions]
(
	[UserID] INT NOT NULL PRIMARY KEY,
	[IsTermsOfUseAccepted] BIT NOT NULL,
	[DoNotShowAboutThisService] BIT NOT NULL,
	CONSTRAINT [FK_UserExtensions_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([ID])
)
