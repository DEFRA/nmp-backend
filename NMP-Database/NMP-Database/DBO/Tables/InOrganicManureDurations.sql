CREATE TABLE [dbo].[InOrganicManureDurations]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(100) NOT NULL,
	[StartDate] INT NOT NULL,	
	[StartMonth] INT NOT NULL,
	[EndDate] INT NOT NULL,
	[EndMonth] INT NOT NULL,
    CONSTRAINT [PK_InOrganicManureDurations] PRIMARY KEY ([ID] ASC)
)
