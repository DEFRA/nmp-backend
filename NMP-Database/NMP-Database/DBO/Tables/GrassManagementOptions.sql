CREATE TABLE [dbo].[GrassManagementOptions]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(50) NOT NULL,
	CONSTRAINT [PK_GrassManagementOptions] PRIMARY KEY ([ID] ASC),
)
