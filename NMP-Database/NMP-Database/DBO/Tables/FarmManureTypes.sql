﻿CREATE TABLE [dbo].[FarmManureTypes]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[FarmID] INT NOT NULL,
	[ManureTypeID] INT NOT NULL,
	[FieldTypeID] INT NOT NULL,
	[DryMatter] [decimal](18, 2) NOT NULL,
	[TotalN] [decimal](18, 2) NOT NULL,
	[NH4N] [decimal](18, 2) NOT NULL,
	[Uric] [decimal](18, 2) NOT NULL,
	[NO3N] [decimal](18, 2) NOT NULL,
	[P2O5] [decimal](18, 2) NOT NULL,
	[K2O] [decimal](18, 2) NOT NULL,
	[SO3] [decimal](18, 2) NOT NULL,
	[MgO] [decimal](18, 2) NOT NULL,
	CONSTRAINT [PK_FarmManureTypes] PRIMARY KEY ([ID] ASC),	
    CONSTRAINT [FK_FarmManureTypes_Farms_FarmID] FOREIGN KEY ([FarmID]) REFERENCES [Farms]([ID]),
    CONSTRAINT [FK_FarmManureTypes_ManureTypes_ManureTypeID] FOREIGN KEY ([ManureTypeID]) REFERENCES [ManureTypes]([ID]),
)
