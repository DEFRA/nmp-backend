CREATE TABLE [dbo].[PreviousCroppings]
(
	[ID]                            INT NOT NULL  IDENTITY(1,1),
	[FieldID]                       INT NOT NULL,
    [CropGroupID]                   INT NULL,
    [CropTypeID]                    INT NULL,
    [HasGrassInLastThreeYear]       BIT NOT NULL,
    [HarvestYear]                   INT NULL,
    [LayDuration]                   INT NULL,
    [GrassManagementOptionID]       INT NULL,
    [HasGreaterThan30PercentClover] BIT NULL,
    [SoilNitrogenSupplyItemID]      INT NULL,
	[CreatedOn]                     DATETIME2 NULL CONSTRAINT DF_PreviousCroppings_CreatedOn DEFAULT GETDATE(), 
    [CreatedByID]                   INT NULL, 
    [ModifiedOn]                    DATETIME2 NULL, 
    [ModifiedByID]                  INT NULL,
    CONSTRAINT [PK_PreviousCroppings] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_PreviousCroppings_Fields] FOREIGN KEY([FieldID]) REFERENCES [dbo].[Fields] ([ID]),
    CONSTRAINT [FK_PreviousCroppings_GrassManagementOptions] FOREIGN KEY([GrassManagementOptionID]) REFERENCES [dbo].[GrassManagementOptions] ([ID]),
    CONSTRAINT [FK_PreviousCroppings_SoilNitrogenSupplyItems] FOREIGN KEY([SoilNitrogenSupplyItemID]) REFERENCES [dbo].[SoilNitrogenSupplyItems] ([ID])
)
