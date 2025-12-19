CREATE TABLE [dbo].[Warnings]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[WarningKey] [nvarchar](200) NOT NULL,
    [CountryID] [int] NOT NULL,
    [Header] [nvarchar](max) NULL,
    [Para1] [nvarchar](max) NULL,
    [Para2] [nvarchar](max) NULL,
    [Para3] [nvarchar](max) NULL,
    CONSTRAINT [PK_Warnings] PRIMARY KEY ([ID] ASC),
    CONSTRAINT UQ_Warnings_WarningKey_CountryID UNIQUE (WarningKey, CountryID)
)
