CREATE TABLE [dbo].[SoilAnalyses]
(
	[ID]             INT IDENTITY(1,1) NOT NULL,
	[FieldID]                   INT             NOT NULL,
    [Year]                      INT             NOT NULL,
    [SulphurDeficient]          BIT             NOT NULL CONSTRAINT DF_SoilAnalyses_SulphurDeficient DEFAULT 1,
    [Date]                      DATETIME        NULL,
    [PH]                        DECIMAL (18, 3) NULL,    
    [PhosphorusMethodologyId]   INT             NULL,
    [Phosphorus]                INT             NULL,
    [PhosphorusIndex]           TINYINT         NULL,
    [Potassium]                 INT             NULL,
    [PotassiumIndex]            TINYINT         NULL, 
    [Magnesium]                 INT             NULL,  
    [MagnesiumIndex]            TINYINT         NULL,    
    [SoilNitrogenSupply]        INT             NULL,
    [SoilNitrogenSupplyIndex]   TINYINT         NULL,
    [Sodium]                    INT             NULL,
    [Lime]                      DECIMAL (18, 3) NULL,    
    [PhosphorusStatus]          NVARCHAR (20)   NULL,
    [PotassiumAnalysis]         NVARCHAR (50)   NULL,
    [PotassiumStatus]           NVARCHAR (20)   NULL,
    [MagnesiumAnalysis]         NVARCHAR (20)   NULL,
    [MagnesiumStatus]           NVARCHAR (20)   NULL,
    [NitrogenResidueGroup]      NVARCHAR (20)   NULL,
    [Comments]                  NVARCHAR (255)  NULL,
    [PreviousId]                INT             NULL,
    CONSTRAINT [PK_SoilAnalyses] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SoilAnalyses_Fields] FOREIGN KEY([FieldId]) REFERENCES [dbo].[Fields] ([Id])

)

