CREATE TABLE [dbo].[Fields]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[FarmID] INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	[NationalGridReference] NVARCHAR(50) NULL,
	[OtherReference] NVARCHAR(50) NULL,
    [LPIDNumber] NVARCHAR(50) NULL,
	[TotalArea] DECIMAL(18,3) NOT NULL,
    [CroppedArea] DECIMAL(18,3) NULL, 
	[ManureNonSpreadingArea] DECIMAL(18,3) NULL,
	[IsWithinNVZ] BIT NULL CONSTRAINT DF_Fields_IsWithinNVZ DEFAULT 0,
	[IsAbove300SeaLevel] BIT NULL CONSTRAINT DF_Fields_IsAbove300SeaLevel DEFAULT 0,
	[SoilTypeID] INT NULL, --RB209
	[SoilReleasingClay] BIT NULL CONSTRAINT DF_Fields_SoilReleasingClay DEFAULT 0,

	[NVZProgrammeID] NVARCHAR(50) NULL, --RB209	
	[IsActive] BIT NOT NULL CONSTRAINT DF_Fields_IsActive DEFAULT 1,
    [CreatedOn] DATETIME2 NULL CONSTRAINT DF_Fields_CreatedOn DEFAULT GETDATE(), 
    [CreatedByID] INT NOT NULL,
	[ModifiedOn] DATETIME2 NULL,
	[ModifiedByID] INT NULL,
    CONSTRAINT [PK_Fields] PRIMARY KEY ([ID] ASC), 
    CONSTRAINT [FK_Fields_Farms] FOREIGN KEY ([FarmID]) REFERENCES [Farms]([ID]),
    CONSTRAINT [FK_Fields_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [Users]([ID]),
    CONSTRAINT [FK_Fields_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [Users]([ID]),
	CONSTRAINT [UC_Fields_FarmName] UNIQUE ([FarmID], [Name])


)
