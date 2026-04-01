CREATE TABLE [dbo].[ScotlandNMaxValues]
(
	[CropTypeID] INT NOT NULL,
	[SoilTypeID] INT NOT NULL,
	[ResidueGroup1] INT NOT NULL,
	[ResidueGroup2] INT NOT NULL,
	[ResidueGroup3] INT NOT NULL,
	[ResidueGroup4] INT NOT NULL,
	[ResidueGroup5] INT NOT NULL,
	[ResidueGroup6] INT NOT NULL,
	CONSTRAINT [UQ_ScotlandNMaxValues_CropTypeID_SoilTypeID] UNIQUE ([CropTypeID],[SoilTypeID])
)
