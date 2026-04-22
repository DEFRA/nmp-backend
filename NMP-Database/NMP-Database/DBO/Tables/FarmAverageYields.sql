CREATE TABLE [dbo].[FarmAverageYields]
(
	[FarmID] INT NOT NULL,
	[HarvestYear] INT NOT NULL,
	[CropTypeID] INT NOT NULL,
	[AverageYield] DECIMAL (18, 3) NOT NULL,
	[CreatedOn] DATETIME2 NULL CONSTRAINT DF_FarmAverageYields_CreatedOn DEFAULT GETDATE(), 
    [CreatedByID] INT NULL,
	[ModifiedOn] DATETIME2 NULL,
	[ModifiedByID] INT NULL,
	CONSTRAINT [FK_FarmAverageYields_Farms] FOREIGN KEY ([FarmID]) REFERENCES [Farms]([ID]),	
    CONSTRAINT [FK_FarmAverageYields_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [Users]([ID]),
    CONSTRAINT [FK_FarmAverageYields_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [Users]([ID]),
)
