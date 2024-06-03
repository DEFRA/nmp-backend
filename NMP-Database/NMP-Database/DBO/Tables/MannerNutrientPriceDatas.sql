CREATE TABLE [dbo].[MannerNutrientPriceDatas]
(
	[ID] INT IDENTITY(1,1) NOT NULL,
	[MannerApplicationID] INT NULL,
	[PriceNPrecise] DECIMAL(18, 12) NULL,
	[PriceP2O5Precise] DECIMAL(18, 12) NULL,
	[PriceK2OPrecise] DECIMAL(18, 12) NULL,
	[PriceN] INT NULL,
	[PriceP2O5] INT NULL,
	[PriceK2O] INT NULL,
	[Price2N] DECIMAL(18, 4) NULL,
	[Price2P2O5] DECIMAL(18, 4) NULL,
	[Price2K2O] DECIMAL(18, 4) NULL,
	[NitrogenTypePercent] BIT NULL,	
    CONSTRAINT [PK_MannerNutrientPriceDatas] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MannerNutrientPriceDatas_MannerApplications] FOREIGN KEY([MannerApplicationID]) REFERENCES [dbo].[MannerApplications] ([ID])
)
