CREATE TABLE [dbo].[FarmsNVZ]
(
	[ID] INT NOT NULL IDENTITY(1,1), 
    [FarmID] INT NOT NULL, 
    [NVZProgrammeID] INT NOT NULL,
    [NVZProgrammeName] NVARCHAR(128) NOT NULL,
    [CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL,
    CONSTRAINT [PK_FarmsNVZ] PRIMARY KEY ([ID] ASC),
    CONSTRAINT [FK_FarmsNVZ_Farms] FOREIGN KEY([FarmID]) REFERENCES [dbo].[Farms] ([ID]),
    CONSTRAINT [FK_FarmsNVZ_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_FarmsNVZ_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID]),
)
