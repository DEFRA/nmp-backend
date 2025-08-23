CREATE TABLE [dbo].[MaterialStates]
(
	[ID] INT NOT NULL IDENTITY(1,1),	
	[Name] NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_MaterialStates] PRIMARY KEY ([ID] ASC),
)
