CREATE TABLE [dbo].[BankSlopeAngles]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(50) NOT NULL,
	[Angle] INT NOT NULL,
	[Slope] INT NOT NULL,
    CONSTRAINT [PK_BankSlopeAngles] PRIMARY KEY ([ID] ASC),

)
