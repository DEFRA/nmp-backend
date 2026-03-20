CREATE TABLE [dbo].[MannerEstimations]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[Name]  NVARCHAR(250) NOT NULL,
	[FarmName]     NVARCHAR(250) NOT NULL,
	[CountryID]    INT  NOT NULL,
	[Postcode]     NVARCHAR (50)   NOT NULL,
	[AverageAnuualRainfall]     INT  NOT NULL,
	[FieldName]    NVARCHAR(250) NOT NULL,
	[IsWithinNVZ]  BIT NOT NULL,
	[NVZProgrammeID] INT NULL, --RB209	
	[SoilTypeID]   INT NOT NULL, --RB209
	[CropTypeID]   INT NOT  NULL,
	[IsEarlySown]         BIT NULL,
	[FieldComments]   NVARCHAR(250)  NULL,	
    [CreatedOn] DATETIME2 NULL CONSTRAINT DF_MannerEstimations_CreatedOn DEFAULT GETDATE(), 
    [CreatedByID] INT NULL,
	[ModifiedOn] DATETIME2 NULL,
	[ModifiedByID] INT NULL,
	CONSTRAINT [PK_MannerEstimations] PRIMARY KEY ([ID] ASC),
	CONSTRAINT [FK_MannerEstimations_Countries] FOREIGN KEY([CountryID]) REFERENCES [dbo].[Countries] ([ID]),
)
