CREATE TABLE [dbo].[FieldExtensions] (
    [FieldID]            INT           NOT NULL,
    [SiteClassID]        INT           NULL,
    [GrassGrowthClassID] INT           NULL,
    [CreatedOn]          DATETIME2 (7) CONSTRAINT [DF_FieldExtension_CreatedOn] DEFAULT (sysdatetime()) NOT NULL,
    [ModifiedOn]         DATETIME2 (7) NULL,
    CONSTRAINT [PK_FieldExtension] PRIMARY KEY CLUSTERED ([FieldID] ASC)
);

