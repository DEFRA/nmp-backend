﻿CREATE TABLE [dbo].[ApplicationMethods]
(
	[ID] INT IDENTITY(1,1) NOT NULL, 
    [Name] NVARCHAR(100) NOT NULL ,
	CONSTRAINT [PK_ApplicationMethods] PRIMARY KEY CLUSTERED ([ID] ASC)
)
