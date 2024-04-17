CREATE TABLE [dbo].[Crops]
(
	[Id]                    INT IDENTITY(1,1) NOT NULL,
	[FieldId]               INT             NOT NULL,
    [Year]                  INT             NOT NULL,
    [CropTypeId]            INT             NULL,    
    [Variety]               NVARCHAR (100)  NULL,
    [CropInfo1]             INT             NULL,
    [CropInfo2]             INT             NULL,
    [SowingDate]            DATETIME        NULL,
    [Yield]                 DECIMAL (18, 3) NULL,
    [Confirm]               BIT             NOT NULL    CONSTRAINT DF_Crops_Confirm DEFAULT 0,    
    [PreviousGrass]         INT             NULL,    
    [GrassHistory]          INT             NULL,
    [Comments]              NVARCHAR (512)  NULL,
    [Establishment]         INT             NULL,
    [LivestockType]         INT             NULL,
    [MilkYield]             DECIMAL(18, 3)  NULL        CONSTRAINT DF_Crops_MilkYield DEFAULT 0,
    [ConcentrateUse]        DECIMAL(18, 3)  NULL        CONSTRAINT DF_Crops_ConcentrateUse DEFAULT 0,
    [StockingRate]          DECIMAL(18, 3)  NULL        CONSTRAINT DF_Crops_StockingRate DEFAULT 0,
    [DefoliationSequence]   INT             NULL,
    [GrazingIntensity]      INT             NULL        CONSTRAINT DF_Crops_GrazingIntensity DEFAULT 0,
    [PreviousId]            INT             NULL,
    CONSTRAINT [PK_Crops] PRIMARY KEY CLUSTERED ([Id] ASC),    
    CONSTRAINT [FK_Crops_Fields] FOREIGN KEY([FieldId]) REFERENCES [dbo].[Fields] ([Id])
)

