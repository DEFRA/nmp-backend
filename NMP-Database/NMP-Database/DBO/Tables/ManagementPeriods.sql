CREATE TABLE [dbo].[ManagementPeriods]
(
	[ID] INT NOT NULL IDENTITY(1,1),
    [CropID] INT NOT NULL,
    [DefoliationID] INT NULL CONSTRAINT DF_ManagementPeriods_Defoliation DEFAULT 1, 
    [Utilisation1ID] INT NULL CONSTRAINT DF_ManagementPeriods_Utilisation1 DEFAULT 0, 
    [Utilisation2ID] INT NULL CONSTRAINT DF_ManagementPeriods_Utilisation2 DEFAULT 0, 
    [Yield] DECIMAL(18, 3) NULL CONSTRAINT DF_ManagementPeriods_Yield DEFAULT 0, 
    [PloughedDown] DATETIME NULL,
    [CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL,
    [PreviousID]    INT NULL,
    CONSTRAINT [PK_ManagementPeriods] PRIMARY KEY CLUSTERED ([ID] ASC), 
    CONSTRAINT [FK_ManagementPeriods_Crops] FOREIGN KEY([CropID]) REFERENCES [dbo].[Crops] ([ID]),
    CONSTRAINT [FK_ManagementPeriods_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_ManagementPeriods_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])
)
