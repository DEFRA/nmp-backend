CREATE TABLE [dbo].[Farms]
(
	[ID]                 INT NOT NULL IDENTITY(1,1),
	[Name]               NVARCHAR (50)   NOT NULL,
    [Address1]           NVARCHAR (50)   NULL,
    [Address2]           NVARCHAR (50)   NULL,
    [Address3]           NVARCHAR (50)   NULL,
    [Address4]           NVARCHAR (50)   NULL,
    [PostCode]           NVARCHAR (50)   NOT NULL,
    [CPH]                NVARCHAR (50)   NULL,
    [FarmerName]         NVARCHAR (128)  NULL,
    [BusinessName]       NVARCHAR (128)  NULL,
    [SBI]                NVARCHAR (20)   NULL,
    [STD]                NVARCHAR (6)    NULL,
    [Telephone]          NVARCHAR (15)   NULL,
    [Mobile]             NVARCHAR (13)   NULL,
    [Email]              NVARCHAR (256)  NULL,
    [Rainfall]           INT             NULL,
    [TotalFarmArea]      DECIMAL (18, 4) NOT NULL CONSTRAINT DF_Farms_TotalFarmArea DEFAULT 0,
    [AverageAltitude]    INT             NOT NULL CONSTRAINT DF_Farms_AverageAltitude DEFAULT 0,
    [RegisteredOrganicProducer] BIT       NOT NULL CONSTRAINT DF_Farms_RegistredOrganicProducer DEFAULT 0,
    [MetricUnits]        BIT             NOT NULL CONSTRAINT DF_Farms_MetricUnits DEFAULT 0,
    [EnglishRules]       BIT             NOT NULL CONSTRAINT DF_Farms_EnglishRules DEFAULT 1,
    [NVZFields]          INT             NOT NULL CONSTRAINT DF_Farms_NVZFields DEFAULT 0,
    [FieldsAbove300SeaLevel]   INT       NOT NULL CONSTRAINT DF_Farms_FieldsAbove300SeaLevel DEFAULT 0,
    [CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL,
    CONSTRAINT [PK_Farms] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_Farms_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_Farms_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])


)

