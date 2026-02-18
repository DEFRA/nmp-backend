CREATE TABLE [dbo].[ScotlandNitrateVulnerableZones]
(
	[ID] INT NOT NULL IDENTITY(1,1), 
    [Name] NVARCHAR(128) NOT NULL,
	CONSTRAINT [PK_ScotlandNitrateVulnerableZones] PRIMARY KEY ([ID] ASC),
)
