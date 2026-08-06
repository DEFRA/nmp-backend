CREATE TABLE [dbo].[MannerFarms]
(
    ID INT IDENTITY(1,1) NOT NULL,
    OrganisationID UNIQUEIDENTIFIER NOT NULL,
    [Name] NVARCHAR(250) NOT NULL,
    CountryID INT NOT NULL,
    Postcode NVARCHAR(50) NULL,
    AverageAnuualRainfall INT NULL,
    RegisteredOrganicProducer BIT NOT NULL  CONSTRAINT DF_MannerFarms_RegisteredOrganicProducer DEFAULT (0),
    [CreatedOn] DATETIME2 NULL CONSTRAINT DF_MannerFarms_CreatedOn DEFAULT GETDATE(), 
    [CreatedByID] INT NULL,
	[ModifiedOn] DATETIME2 NULL,
	[ModifiedByID] INT NULL,

    CONSTRAINT [PK_MannerFarms] 
        PRIMARY KEY CLUSTERED ([ID] ASC),

    CONSTRAINT FK_MannerFarms_Countries
        FOREIGN KEY (CountryID)
        REFERENCES dbo.Countries(ID),

    CONSTRAINT FK_MannerFarms_Organisations
        FOREIGN KEY (OrganisationID)
        REFERENCES dbo.Organisations(ID),

    CONSTRAINT UQ_MannerFarms_Name_OrganisationID
    UNIQUE ([Name], [OrganisationID]),
    CONSTRAINT [FK_MannerFarms_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [Users]([ID]),
    CONSTRAINT [FK_MannerFarms_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [Users]([ID])
);