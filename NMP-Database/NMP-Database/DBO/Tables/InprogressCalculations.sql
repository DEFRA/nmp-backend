CREATE TABLE [dbo].[InprogressCalculations]
(
        [ID] [int] IDENTITY(1,1) NOT NULL,
		[FarmID] INT NOT NULL,
		CONSTRAINT [PK_InprogressCalculations] PRIMARY KEY ([ID] ASC),
		CONSTRAINT [FK_InprogressCalculations_Farms] FOREIGN KEY ([FarmID]) REFERENCES [Farms]([ID]),

)
