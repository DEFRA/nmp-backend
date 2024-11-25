﻿CREATE TABLE [dbo].[OrganicManures] (
    [ID]                       INT             IDENTITY (1, 1) NOT NULL,
    [ManagementPeriodID]       INT             NOT NULL,
    [ManureTypeID]             INT             NOT NULL,
    [ApplicationDate]          DATETIME        NULL,
    [Confirm]                  BIT             NULL,
    [N]                        DECIMAL (18, 3) NOT NULL,
    [P2O5]                     DECIMAL (18, 3) NOT NULL,
    [K2O]                      DECIMAL (18, 3) NOT NULL,
    [MgO]                      DECIMAL (18, 3) NOT NULL,
    [SO3]                      DECIMAL (18, 3) NOT NULL,    
    [ApplicationRate]          INT             NOT NULL,
    [DryMatterPercent]         DECIMAL (18, 2) NOT NULL,
    [UricAcid]                 DECIMAL (18, 2) NOT NULL,
    [EndOfDrain]               DATETIME        NULL,
    [Rainfall]                 INT             NOT NULL,
    [AreaSpread]               DECIMAL (18, 3) NULL,
    [ManureQuantity]           DECIMAL (18, 3) NULL,
    [ApplicationMethodID]      INT             NOT NULL,
    [IncorporationMethodID]    INT             NOT NULL,
    [IncorporationDelayID]     INT             NOT NULL,
    [NH4N]                     DECIMAL (18, 3) NOT NULL,
    [NO3N]                     DECIMAL (18, 3) NOT NULL,
    [AvailableN]               DECIMAL (18, 3) NOT NULL,
    [AvailableSO3]             DECIMAL (18, 3) NULL,
    [AvailableP2O5]            DECIMAL (18, 3) NULL,
    [AvailableK2O]             DECIMAL (18, 3) NULL,    
    [WindspeedID]              INT             NULL,
    [RainfallWithinSixHoursID] INT             NULL,
    [MoistureID]               INT             NULL,
    [AutumnCropNitrogenUptake] DECIMAL (5, 2)  CONSTRAINT [DF_OrganicManures_AutumnCropNitrogenUptake] DEFAULT ((0)) NOT NULL,
    [CreatedOn]                DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [CreatedByID]              INT             NULL,
    [ModifiedOn]               DATETIME2 (7)   NULL,
    [ModifiedByID]             INT             NULL,
    CONSTRAINT [PK_OrganicManures] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_OrganicManures_ManagementPeriods] FOREIGN KEY ([ManagementPeriodID]) REFERENCES [dbo].[ManagementPeriods] ([ID]),
    CONSTRAINT [FK_OrganicManures_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_OrganicManures_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])
);


