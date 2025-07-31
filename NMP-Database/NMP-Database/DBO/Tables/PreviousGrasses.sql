CREATE TABLE [dbo].[PreviousGrasses]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[FieldID] INT NOT NULL,
    [HasGrassInLastThreeYear] BIT NOT NULL,
    [HarvestYear] INT NULL,
    [LayDuration] INT NULL,
    [GrassManagementOptionID] INT NULL,
    [HasGreaterThan30PercentClover] BIT NULL,
    [SoilNitrogenSupplyItemID] INT NULL,
	[CreatedOn] DATETIME2 NULL CONSTRAINT DF_PreviousGrasses_CreatedOn DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL,
    CONSTRAINT [PK_PreviousGrasses] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_PreviousGrasses_Fields] FOREIGN KEY([FieldID]) REFERENCES [dbo].[Fields] ([ID]),
    CONSTRAINT [FK_PreviousGrasses_GrassManagementOptions] FOREIGN KEY([GrassManagementOptionID]) REFERENCES [dbo].[GrassManagementOptions] ([ID]),
    CONSTRAINT [FK_PreviousGrasses_SoilNitrogenSupplyItems] FOREIGN KEY([SoilNitrogenSupplyItemID]) REFERENCES [dbo].[SoilNitrogenSupplyItems] ([ID])
)
