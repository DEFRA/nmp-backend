CREATE TABLE [dbo].[SolidManureTypes]
(
	[ID] INT NOT NULL  IDENTITY(1,1),	
	[Name] NVARCHAR(50) NOT NULL,
	[Density] DECIMAL(18,1)  NOT NULL,
    CONSTRAINT [PK_SolidManureTypes] PRIMARY KEY ([ID] ASC),
)
