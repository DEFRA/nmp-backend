CREATE TABLE [dbo].[PreviousGrassIdMapping]
(
	[ID] INT NOT NULL IDENTITY(1,1),
    [FirstHYFieldType] INT NULL, 
    [SecondHYFieldType] INT NULL, 
    [ThirdHYFieldType] INT NULL, 
    [LayDuration] INT NULL,    --1 for 1 to 2 years, 2 for 3 to 5 years
    [IsGrazedOnly] BIT NULL, 
    [IsHighClover] BIT NULL, 
    [NitrogenUse] NVARCHAR(20) NULL, 
    [PreviousGrassID] INT NULL,
    CONSTRAINT [PK_PreviousGrassIdMapping] PRIMARY KEY ([ID] ASC),
)
