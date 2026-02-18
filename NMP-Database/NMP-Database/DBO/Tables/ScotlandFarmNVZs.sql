CREATE TABLE [dbo].[ScotlandFarmNVZs]
(
	[ID] INT NOT NULL IDENTITY(1,1), 
    [FarmID] INT NOT NULL, 
    [ScotlandNitrateVulnerableZoneID] INT NOT NULL,
    CONSTRAINT [PK_ScotlandFarmNVZs] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_ScotlandFarmNVZs_Farms] FOREIGN KEY([FarmID]) REFERENCES [dbo].[Farms] ([ID]),
    CONSTRAINT [FK_ScotlandFarmNVZs_ScotlandNitrateVulnerableZones] FOREIGN KEY([ScotlandNitrateVulnerableZoneID]) REFERENCES [dbo].[ScotlandNitrateVulnerableZones] ([ID])
)
