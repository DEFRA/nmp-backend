CREATE TABLE [dbo].[DefaultValueAgainstFarmAndManureType]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[FarmID] INT NOT NULL,
	[ManureTypeID] INT NOT NULL,
	[DryMatter] [decimal](18, 2) NULL,
	[TotalN] [decimal](18, 2) NULL,
	[NH4N] [decimal](18, 2) NULL,
	[Uric] [decimal](18, 2) NULL,
	[NO3N] [decimal](18, 2) NULL,
	[P2O5] [decimal](18, 2) NULL,
	[K2O] [decimal](18, 2) NULL,
	[SO3] [decimal](18, 2) NULL,
	[MgO] [decimal](18, 2) NULL,
	CONSTRAINT [PK_DefaultValueAgainstFarmAndManureType] PRIMARY KEY ([ID] ASC)
)
