CREATE TABLE [dbo].[RainTypes]
(
	[ID] INT identity(1,1) NOT NULL,
	[Name] NVARCHAR(100)   NOT NULL  ,
	[RainInMM] INT   NOT NULL  ,
	CONSTRAINT [PK_RainTypes] PRIMARY KEY CLUSTERED ([ID] ASC)	 
)
