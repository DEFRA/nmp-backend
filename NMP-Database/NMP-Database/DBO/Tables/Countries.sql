﻿CREATE TABLE [dbo].[Countries]
(
	[ID] INT NOT NULL IDENTITY(1,1),
	[Name] NVARCHAR(50) NOT NULL,	
    CONSTRAINT [PK_Countries] PRIMARY KEY ([ID] ASC),
)
