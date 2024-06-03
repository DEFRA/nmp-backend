CREATE TABLE [dbo].[ManureTypes]
(
	[ID] INT IDENTITY(1,1) NOT NULL,
	[Name] NVARCHAR(50)  NULL,
	[Arable] NVARCHAR(50) NULL,
	[Obsolete] BIT  NULL,
	[IsLiquid] BIT  NULL,
	[OrderBy] INT  NULL,
	CONSTRAINT [PK_ManureTypes] PRIMARY KEY CLUSTERED ([ID] ASC),
)
