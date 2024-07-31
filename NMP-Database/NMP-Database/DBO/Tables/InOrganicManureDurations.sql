CREATE TABLE [dbo].[InOrganicManureDurations]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(100) NOT NULL,
	[ApplicationDate] INT NOT NULL,	
	[ApplicationMonth] INT NOT NULL,
    CONSTRAINT [PK_InOrganicManureDurations] PRIMARY KEY ([ID] ASC)
)
