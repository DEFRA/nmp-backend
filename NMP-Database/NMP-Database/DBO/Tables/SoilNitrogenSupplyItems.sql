CREATE TABLE [dbo].[SoilNitrogenSupplyItems]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(50) NOT NULL,	
	[SoilNitrogenSupplyId] INT NOT NULL,
    CONSTRAINT [PK_SoilNitrogenSupplyItems] PRIMARY KEY ([ID] ASC),
)
