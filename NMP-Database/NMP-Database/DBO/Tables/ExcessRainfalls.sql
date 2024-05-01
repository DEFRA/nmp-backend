CREATE TABLE [dbo].[ExcessRainfalls]
(
    [FarmID] INT NOT NULL ,
	[Year] INT NOT NULL, 
    [ExcessRainfall] INT NULL CONSTRAINT DF_ExcessRainfalls_ExcessRainfall DEFAULT 0, 
    [WinterRainfall] INT NULL,
    [CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NULL, 
    [ModifiedOn] DATETIME2 NULL, 
    [ModifiedByID] INT NULL, 
    CONSTRAINT [PK_ExcessRainfall] PRIMARY KEY CLUSTERED ([FarmID],[Year] ASC),    
    CONSTRAINT [FK_ExcessRainfall_Farms] FOREIGN KEY([FarmID]) REFERENCES [dbo].[Farms] ([ID]),
    CONSTRAINT [FK_ExcessRainfall_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_ExcessRainfall_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])

);

