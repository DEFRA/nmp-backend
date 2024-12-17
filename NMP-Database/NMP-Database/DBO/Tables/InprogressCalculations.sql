CREATE TABLE [dbo].[InprogressCalculations]
(
		[FieldID] INT NOT NULL,
		[Year] INT NOT NULL, 
        CONSTRAINT [PK_InprogressCalculations] PRIMARY KEY CLUSTERED ([FieldID] ASC, [Year] ASC),
)
