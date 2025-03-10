﻿CREATE TABLE [dbo].[SoilAnalyses]
(
	[ID]             INT IDENTITY(1,1) NOT NULL,
	[FieldID]                   INT             NOT NULL,
    [Year]                      INT             NOT NULL,
    [SulphurDeficient]          BIT             NOT NULL CONSTRAINT DF_SoilAnalyses_SulphurDeficient DEFAULT 1,
    [Date]                      DATETIME2        NULL,
    [PH]                        DECIMAL (18, 3) NULL,    
    [PhosphorusMethodologyID]   INT             NULL,
    [Phosphorus]                INT             NULL,
    [PhosphorusIndex]           TINYINT         NULL,
    [Potassium]                 INT             NULL,
    [PotassiumIndex]            SMALLINT         NULL, 
    [Magnesium]                 INT             NULL,  
    [MagnesiumIndex]            TINYINT         NULL,    
    [SoilNitrogenSupply]        INT             NULL,
    [SoilNitrogenSupplyIndex]   TINYINT         NULL,
    [SoilNitrogenSampleDate]    DATETIME2       NULL,
    [Sodium]                    INT             NULL,
    [Lime]                      DECIMAL (18, 3) NULL,    
    [PhosphorusStatus]          NVARCHAR (20)   NULL,
    [PotassiumAnalysis]         NVARCHAR (50)   NULL,
    [PotassiumStatus]           NVARCHAR (20)   NULL,
    [MagnesiumAnalysis]         NVARCHAR (20)   NULL,
    [MagnesiumStatus]           NVARCHAR (20)   NULL,
    [NitrogenResidueGroup]      NVARCHAR (20)   NULL,
    [Comments]                  NVARCHAR (255)  NULL,
    [CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL,
    [PreviousID]                INT             NULL,
    CONSTRAINT [PK_SoilAnalyses] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SoilAnalyses_Fields] FOREIGN KEY([FieldID]) REFERENCES [dbo].[Fields] ([ID]),
    CONSTRAINT [FK_SoilAnalyses_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_SoilAnalyses_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])

)

