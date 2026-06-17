CREATE TABLE [dbo].[MannerEstimationFinancialValues]
(
	[Id] INT   IDENTITY (1, 1) NOT NULL,
    [MannerEstimationApplicationID] INT NOT NULL,
    [NitrogenValue] INT NOT NULL,
    [PhosphateValue] INT NOT NULL,
    [PotashValue] INT NOT NULL,

    [NitrogenProductId] INT NOT NULL,
    [PhosphateProductId] INT NOT NULL,
    [PotashProductId] INT NOT NULL,

    [NitrogenProductName] NVARCHAR(100) NOT NULL,
    [PhosphateProductName] NVARCHAR(100) NOT NULL,
    [PotashProductName] NVARCHAR(100) NOT NULL,

    [NitrogenProductPrice] INT NOT NULL,
    [PhosphateProductPrice] INT NOT NULL,
    [PotashProductPrice] INT NOT NULL,

    [NitrogenPrice] INT NOT NULL,
    [PhosphatePrice] INT NOT NULL,
    [PotashPrice] INT NOT NULL,

    [CreatedOn]             DATETIME2       NULL DEFAULT GETDATE(), 
    [CreatedByID]           INT             NULL,
    [ModifiedOn]            DATETIME2       NULL,
    [ModifiedByID]          INT             NULL,
    CONSTRAINT [PK_MannerFinancialValues] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MannerFinancialValues_MannerEstimationApplications] FOREIGN KEY ([MannerEstimationApplicationID]) REFERENCES [dbo].[MannerEstimationApplications] ([ID]),
    CONSTRAINT [FK_MannerFinancialValues_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_MannerFinancialValuesj_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])
)
