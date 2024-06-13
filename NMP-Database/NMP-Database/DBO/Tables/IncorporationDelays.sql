CREATE TABLE [dbo].[IncorporationDelays] (
    [ID]        INT IDENTITY(1,1) NOT NULL,
    [Name]      NVARCHAR (100) NOT NULL,
    [FromHours] INT            NULL,
    [ToHours]   INT            NULL,
    CONSTRAINT [PK_IncorporationDelays] PRIMARY KEY CLUSTERED ([ID] ASC)
);


