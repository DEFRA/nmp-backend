CREATE TABLE [dbo].[StorageTypes]
(
	[ID] INT NOT NULL  IDENTITY(1,1),	
	[Name] NVARCHAR(50) NOT NULL,
	[FreeBoardHeight] DECIMAL(18,2) NOT NULL,
    CONSTRAINT [PK_StorageTypes] PRIMARY KEY ([ID] ASC),
)
