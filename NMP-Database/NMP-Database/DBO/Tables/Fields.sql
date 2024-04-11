CREATE TABLE [dbo].[Fields]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[FarmID] INT NOT NULL,
	[SoilTypeID] INT NULL, --RB209
	[NVZProgrammeID] NVARCHAR(50) NULL, --RB209
	[Name] NVARCHAR(50) NOT NULL,
    [LPIDNumber] NVARCHAR(50) NULL,
	[NationalGridReference] NVARCHAR(50) NULL,
	[TotalArea] DECIMAL(18,3) NULL,
    [CroppedArea] DECIMAL(18,3) NULL, 
	[ManureNonSpreadingArea] DECIMAL(18,3) NULL,
	[SoilReleasingClay] BIT NULL DEFAULT 0, 
	[IsWithinNVZ] BIT NULL DEFAULT 0,
	[IsAbove300SeaLevel] BIT NULL DEFAULT 0,
    [CreatedOn] DATETIME2 NULL DEFAULT GETDATE(), 
    [CreatedByID] INT NOT NULL,
	[ModifiedOn] DATETIME2 NULL,
	[ModifiedByID] INT NULL,
    CONSTRAINT [PK_Fields] PRIMARY KEY ([ID] ASC), 
    CONSTRAINT [FK_Fields_Farms] FOREIGN KEY ([FarmID]) REFERENCES [Farms]([ID]),
    CONSTRAINT [FK_Fields_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [Users]([ID]),
    CONSTRAINT [FK_Fields_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [Users]([ID]),
	CONSTRAINT [UC_Fields_FarmName] UNIQUE ([FarmID], [Name])


)
