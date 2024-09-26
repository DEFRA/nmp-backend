CREATE TABLE [dbo].[SoilTypeSoilTextures]
(
	[SoilTypeID] INT NOT NULL, 
    [TopSoilID] INT NOT NULL,
	[SubSoilID] INT NOT NULL,
	
	CONSTRAINT [PK_SoilTypeSoilTextures] PRIMARY KEY CLUSTERED ([SoilTypeID] ASC)
)