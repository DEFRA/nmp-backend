CREATE TABLE [dbo].[ExcessWinterRainfallOptions]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(50) NOT NULL,	
	[Value]  INT NOT NULL,
    CONSTRAINT [PK_ExcessWinterRainfallOptions] PRIMARY KEY ([ID] ASC),
)
