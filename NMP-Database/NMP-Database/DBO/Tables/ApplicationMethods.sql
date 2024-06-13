CREATE TABLE [dbo].[ApplicationMethods]
(
	[ID] INT  NOT NULL IDENTITY(1,1), 
    [Name] NVARCHAR(100) NOT NULL ,
	[ApplicableFor] NVARCHAR(1) NOT NULL ,
	CONSTRAINT [PK_ApplicationMethods] PRIMARY KEY CLUSTERED ([ID] ASC)
)
