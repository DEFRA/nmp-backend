CREATE TABLE [dbo].[Warnings] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [WarningKey] NVARCHAR (200) NOT NULL,
    [CountryID]  INT            NOT NULL,
    [Header]     NVARCHAR (MAX) NULL,
    [Para1]      NVARCHAR (MAX) NULL,
    [Para2]      NVARCHAR (MAX) NULL,
    [Para3]      NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_Warnings_WarningKey_Country] UNIQUE NONCLUSTERED ([WarningKey] ASC, [CountryID] ASC)
);

