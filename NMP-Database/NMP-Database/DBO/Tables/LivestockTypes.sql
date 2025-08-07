CREATE TABLE [dbo].[LivestockTypes] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [LivestockGroupID] INT            NOT NULL,
    [Name]             VARCHAR (255)  NOT NULL,
    [NByUnit]          DECIMAL (8, 2) NULL,
    [NByUnitCalc]      DECIMAL (8, 2) NULL,
    [P2O5]             DECIMAL (8, 2) NULL,
    [P2O5Calc]         DECIMAL (8, 2) NULL,
    [Occupancy]        DECIMAL (8, 2) NULL,
    [IsGrazing]        BIT            NULL,
    [OrderBy]          INT            NULL,    
    CONSTRAINT [PK_LivestockTypes] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_LivestockTypes_LivestockGroups] FOREIGN KEY ([LivestockGroupID]) REFERENCES [dbo].[LivestockGroups] ([ID])
);

