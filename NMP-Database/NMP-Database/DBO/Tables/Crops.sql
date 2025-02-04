﻿CREATE TABLE [dbo].[Crops]
(
	[ID]                    INT IDENTITY(1,1) NOT NULL,
	[FieldID]               INT             NOT NULL,
    [Year]                  INT             NOT NULL,
    [CropTypeID]            INT             NULL,   
    [FieldType]             INT             NOT NULL CONSTRAINT DF_Crops_FieldType DEFAULT 1,
    [Variety]               NVARCHAR (100)  NULL,    
    [OtherCropName]         NVARCHAR (128)  NULL,
    [CropInfo1]             INT             NULL,
    [CropInfo2]             INT             NULL,
    [SowingDate]            DATETIME2        NULL,
    [Yield]                 DECIMAL (18, 3) NULL,
    [CropGroupName]         NVARCHAR (120)  NULL,    
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
    [CropOrder]             INT             NOT NULL    CONSTRAINT DF_Crops_CropOrder DEFAULT 1,
    [CreatedOn]             DATETIME2       NULL DEFAULT GETDATE(), 
    [CreatedByID]           INT             NULL, 
    [ModifiedOn]            DATETIME2       NULL, 
    [ModifiedByID]          INT             NULL,
    [PreviousID]            INT             NULL,
    CONSTRAINT [PK_Crops] PRIMARY KEY CLUSTERED ([ID] ASC),    
    CONSTRAINT [FK_Crops_Fields] FOREIGN KEY([FieldID]) REFERENCES [dbo].[Fields] ([ID]),
    CONSTRAINT [FK_Crops_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_Crops_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID]),
)

