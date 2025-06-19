CREATE TABLE [dbo].[ManagementPeriods] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [CropID]         INT             NOT NULL,
    [Defoliation]    INT             CONSTRAINT [DF_ManagementPeriods_Defoliation] DEFAULT ((1)) NULL,
    [Utilisation1ID] INT             CONSTRAINT [DF_ManagementPeriods_Utilisation1] DEFAULT ((0)) NULL,
    [Utilisation2ID] INT             CONSTRAINT [DF_ManagementPeriods_Utilisation2] DEFAULT ((0)) NULL,
    [Yield]          DECIMAL (18, 3) CONSTRAINT [DF_ManagementPeriods_Yield] DEFAULT ((0)) NULL,
    [PloughedDown]   DATETIME2 (7)   NULL,
    [CreatedOn]      DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [CreatedByID]    INT             NULL,
    [ModifiedOn]     DATETIME2 (7)   NULL,
    [ModifiedByID]   INT             NULL,
    [PreviousID]     INT             NULL,
    CONSTRAINT [PK_ManagementPeriods] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ManagementPeriods_Crops] FOREIGN KEY ([CropID]) REFERENCES [dbo].[Crops] ([ID]),
    CONSTRAINT [FK_ManagementPeriods_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_ManagementPeriods_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])
);


