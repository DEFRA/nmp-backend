CREATE TABLE [dbo].[InprogressCalculations]
(
		[FarmID] INT NOT NULL,
		CONSTRAINT [FK_InprogressCalculations_Farms] FOREIGN KEY ([FarmID]) REFERENCES [Farms]([ID]),
)
