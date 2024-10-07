CREATE TABLE [dbo].[SnsAnalyses]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [FieldID] INT NOT NULL,
    [SampleDate] DATETIME2 NULL, 
    [SnsAt0to30cm] INT NULL, 
    [SnsAt30to60cm] INT NULL, 
    [SnsAt60to90cm] INT NULL, 
    [SampleDepth] INT NULL, 
    [SoilMineralNitrogen] INT NULL, 
    [NumberOfShoots] INT NULL, 
    [CropHeight] DECIMAL(18, 3) NULL, 
    [SeasonId] INT NULL, 
    [PercentageOfOrganicMatter] DECIMAL(18, 3) NULL, 
    [AdjustmentValue] DECIMAL(18, 3) NULL, 
    [SoilNitrogenSupplyValue] INT NULL, 
    [SoilNitrogenSupplyIndex] TINYINT NULL,
    [CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL
)
