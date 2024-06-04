CREATE TABLE [dbo].[IncorporationMethods]
(
    [ID] INT IDENTITY(1,1) NOT NULL, 
    [Name] NVARCHAR(100) NOT NULL ,
	CONSTRAINT [PK_IncorporationMethods] PRIMARY KEY CLUSTERED ([ID] ASC),	
)
