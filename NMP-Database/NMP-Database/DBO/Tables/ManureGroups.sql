﻿CREATE TABLE [dbo].[ManureGroups]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(50) NOT NULL,	
    CONSTRAINT [PK_ManureGroups] PRIMARY KEY ([ID] ASC)
)
