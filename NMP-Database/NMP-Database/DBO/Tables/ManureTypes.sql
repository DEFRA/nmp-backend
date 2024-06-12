CREATE TABLE [dbo].[ManureTypes]
(
	[ID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ManureGroupID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[HighReadielyAvailableNitrogen] [bit] NOT NULL,
	[IsLiquid] [bit] NOT NULL,
	[DryMatter] [decimal](18, 2) NULL,
	[TotalN] [decimal](18, 2) NULL,
	[NH4N] [decimal](18, 2) NULL,
	[Uric] [decimal](18, 2) NULL,
	[NO3N] [decimal](18, 2) NULL,
	[P2O5] [decimal](18, 2) NULL,
	[K2O] [decimal](18, 2) NULL,
	[SO3] [decimal](18, 2) NULL,
	[MgO] [decimal](18, 2) NULL,
	[P2O5Available] [int] NULL,
	[K2OAvailable] [int] NULL,
	[NMaxConstant] [decimal](18, 2) NULL,
	[ApplicationRateArable] [int] NULL,
	[ApplicationRateGrass] [int] NULL,	
	CONSTRAINT [PK_ManureTypes] PRIMARY KEY CLUSTERED ([ID] ASC),	
	CONSTRAINT [FK_ManureTypes_ManureGroups_ManureGroupID] FOREIGN KEY (ManureGroupID) REFERENCES ManureGroups(ID),
    CONSTRAINT [FK_ManureTypes_Countries_CountryID] FOREIGN KEY (CountryID) REFERENCES Countries(ID)

)
