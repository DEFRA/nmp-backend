CREATE TABLE [dbo].[NutrientsLoadingManures] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [FarmId]           INT             NOT NULL,
    [ManureLookupType] NVARCHAR (250)  NULL,
    [ManureTypeId]     INT             NULL,
    [ManureType]       NVARCHAR (250)  NULL,
    [Quantity]         DECIMAL (18, 3) NULL,
    [NContent]         DECIMAL (18, 3) NULL,
    [NTotal]           INT             NULL,
    [PContent]         DECIMAL (18, 3) NULL,
    [PTotal]           INT             NULL,
    [ManureDate]       DATETIME        NULL,
    [FarmName]         NVARCHAR (50)   NULL,
    [Address1]         NVARCHAR (50)   NULL,
    [Address2]         NVARCHAR (50)   NULL,
    [Address3]         NVARCHAR (50)   NULL,
    [Address4]         NVARCHAR (50)   NULL,
    [PostCode]         NVARCHAR (50)   NULL,
    [Comments]         NVARCHAR (255)  NULL,    
    CONSTRAINT [PK_NutrientsLoadingManures] PRIMARY KEY ([ID] ASC)
);

