﻿CREATE TABLE [dbo].[FertiliserManures]
(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ManagementPeriodID] [int] NOT NULL,
	[ApplicationDate] [datetime] NOT NULL,
	[ApplicationRate] [int] NOT NULL,
	[Confirm] [bit] NULL,
	[N] [decimal](18, 3) NOT NULL,
	[P2O5] [decimal](18, 3) NOT NULL,
	[K2O] [decimal](18, 3) NOT NULL,
	[MgO] [decimal](18, 3) NOT NULL,
	[SO3] [decimal](18, 3) NOT NULL,
	[Na2O] [decimal](18, 3) NOT NULL,
	[NFertAnalysisPercent] [decimal](18, 3) NOT NULL,
	[P2O5FertAnalysisPercent] [decimal](18, 3) NOT NULL,
	[K2OFertAnalysisPercent] [decimal](18, 3) NOT NULL,
	[MgOFertAnalysisPercent] [decimal](18, 3) NOT NULL,
	[SO3FertAnalysisPercent] [decimal](18, 3) NOT NULL,
	[Na2OFertAnalysisPercent] [decimal](18, 3) NOT NULL,
	[Lime] [decimal](18, 3) NOT NULL,
	[NH4N] [decimal](18, 3) NOT NULL,
	[NO3N] [decimal](18, 3) NOT NULL,
	[CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL,
	CONSTRAINT [PK_FertiliserManures] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FertiliserManures_ManagementPeriods_ManagementPeriodId] FOREIGN KEY([ManagementPeriodId]) REFERENCES [dbo].[ManagementPeriods] ([ID]),
	 CONSTRAINT [FK_FertiliserManures_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_FertiliserManures_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])
)	
