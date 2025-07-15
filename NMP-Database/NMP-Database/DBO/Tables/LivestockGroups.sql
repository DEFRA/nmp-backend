CREATE TABLE [dbo].[LivestockGroups] (
    [ID]   INT           IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_LivestockGroups] PRIMARY KEY ([ID] ASC)
);

