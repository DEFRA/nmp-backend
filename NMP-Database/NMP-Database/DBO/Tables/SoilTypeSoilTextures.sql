CREATE TABLE [dbo].[SoilTypeSoilTextures]
(
	[SoilTypeID] INT NOT NULL, 
    [TopSoilID] INT NOT NULL,
	[SubSoilID] INT NOT NULL,
	
	CONSTRAINT [PK_SoilTypeSoilTextures] PRIMARY KEY CLUSTERED ([SoilTypeID] ASC),
	CONSTRAINT [FK_SoilTypeSoilTextures_TopSoils] FOREIGN KEY ([TopSoilID]) REFERENCES [TopSoils]([ID]),
	CONSTRAINT [FK_SoilTypeSoilTextures_SubSoils] FOREIGN KEY ([SubSoilID]) REFERENCES [SubSoils]([ID]),
)