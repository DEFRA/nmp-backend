CREATE TABLE [dbo].[CropInfoQuestions]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[CropInfoOne] NVARCHAR(250),
	CONSTRAINT [PK_CropInfoQuestions] PRIMARY KEY ([ID] ASC),
)
