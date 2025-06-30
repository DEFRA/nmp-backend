CREATE TABLE [dbo].[NutrientsLoadingFarmDetails] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [FarmId]          INT             NOT NULL,
    [CalendarYear]    INT             NOT NULL,
    [LandInNVZ]       DECIMAL (18, 3) NULL,
    [LandNotNVZ]      DECIMAL (18, 3) NULL,
    [TotalFarmed]     DECIMAL (18, 3) NULL,
    [ManureTotal]     INT             NULL,
    [Derogation]      BIT             NOT NULL,
    [GrassPercentage] INT             NULL,
    [ContingencyPlan] BIT             NOT NULL,
    CONSTRAINT [PK_NutrientsLoadingFarmDetails] PRIMARY KEY ([ID] ASC)
);

