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
    [STD]                NVARCHAR (6)    NOT NULL,
    [Telephone]          NVARCHAR (15)   NULL,
    [Mobile]             NVARCHAR (13)   NULL,
    [Email]              NVARCHAR (256)  NULL,
    [Rainfall]           INT             NULL,
    [TotalFarmArea]      DECIMAL (18, 4) NULL CONSTRAINT DF_Farms_TotalFarmArea DEFAULT 0,
    [AverageAltitude]    INT             NULL CONSTRAINT DF_Farms_AverageAltitude DEFAULT 0,
    [RegistredOrganicProducer] BIT     NOT NULL CONSTRAINT DF_Farms_RegistredOrganicProducer DEFAULT 0,
    [MetricUnits]        BIT             NULL CONSTRAINT DF_Farms_MetricUnits DEFAULT 0,
    [EnglishRules]       BIT             NULL CONSTRAINT DF_Farms_EnglishRules DEFAULT 1,
    CONSTRAINT [PK_Farms] PRIMARY KEY ([ID] ASC)


)

