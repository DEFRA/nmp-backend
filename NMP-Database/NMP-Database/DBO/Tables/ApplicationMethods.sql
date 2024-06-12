CREATE TABLE [dbo].[ApplicationMethods]
(
	[ID] INT  NOT NULL, 
    [Name] NVARCHAR(100) NOT NULL ,
	[ApplicableFor] NVARCHAR(1) NOT NULL ,
	CONSTRAINT [PK_ApplicationMethods] PRIMARY KEY CLUSTERED ([ID] ASC)
)
