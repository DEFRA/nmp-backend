CREATE TABLE [dbo].[NutrientsLoadingFarmDetails] (
    [ID]              INT             IDENTITY (1, 1) NOT NULL,
    [FarmID]          INT             NOT NULL,
    [CalendarYear]    INT             NOT NULL,
    [LandInNVZ]       DECIMAL (18, 3) NULL,
    [LandNotNVZ]      DECIMAL (18, 3) NULL,
    [TotalFarmed]     DECIMAL (18, 3) NULL,
    [ManureTotal]     INT             NULL,
    [Derogation]      BIT             NOT NULL,
    [GrassPercentage] INT             NULL,
    [ContingencyPlan] BIT             NOT NULL,
    [CreatedOn]       DATETIME2       NULL DEFAULT GETDATE(), 
    [CreatedByID]     INT             NULL, 
    [ModifiedOn]      DATETIME2       NULL, 
    [ModifiedByID]    INT             NULL,
    CONSTRAINT [PK_NutrientsLoadingFarmDetails] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_NutrientsLoadingFarmDetails_Farms] FOREIGN KEY ([FarmID]) REFERENCES [Farms]([ID]),
    CONSTRAINT [UQ_FarmID_CalendarYear] UNIQUE ([FarmID], [CalendarYear])
);

