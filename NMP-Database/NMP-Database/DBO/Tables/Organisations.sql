﻿CREATE TABLE [dbo].[Organisations]
(
	[ID] UNIQUEIDENTIFIER NOT NULL, 
    [Name] NVARCHAR(512) NOT NULL,
	CONSTRAINT [PK_Organisations] PRIMARY KEY ([ID] ASC),
)
