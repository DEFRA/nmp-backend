CREATE TABLE [dbo].[ExcessRainfalls]
(
    [FarmID] INT NOT NULL ,
	[Year] INT NOT NULL, 
    [ExcessRainfall] INT NULL CONSTRAINT DF_ExcessRainfalls_ExcessRainfall DEFAULT 0, 
    [WinterRainfall] INT NULL,
    CONSTRAINT [PK_ExcessRainfall] PRIMARY KEY CLUSTERED ([FarmID],[Year] ASC),    
    CONSTRAINT [FK_ExcessRainfall_Farms] FOREIGN KEY([FarmID]) REFERENCES [dbo].[Farms] ([ID])
);

