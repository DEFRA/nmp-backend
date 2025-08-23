CREATE TABLE [dbo].[StorageTypes]
(
	[ID] INT NOT NULL  IDENTITY(1,1),	
	[MaterialStatesID] INT NOT NULL,	
	[Name] NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_StorageTypes] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_StorageTypes_MaterialStates] FOREIGN KEY ([ID]) REFERENCES [MaterialStates]([ID]),
)
