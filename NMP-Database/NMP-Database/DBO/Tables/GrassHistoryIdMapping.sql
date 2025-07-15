CREATE TABLE [dbo].[GrassHistoryIdMapping]
(
	[ID] INT NOT NULL IDENTITY(1,1),
    [FirstHYFieldType] INT NULL,
	[SecondHYFieldType] INT NULL, 
	[IsReseeded] BIT NULL,
	[IsHighClover] BIT NULL,
	[NitrogenUse] NVARCHAR(20) NULL, 
	[SoilGroupCategoryID] INT NULL,
	[CropGroupCategoryID] INT NULL,
	[GrassHistoryID] INT NULL,
	CONSTRAINT [PK_GrassHistoryIdMapping] PRIMARY KEY ([ID] ASC)
)
