CREATE TABLE [dbo].[FarmManureTypes] (
    [ID]           INT             IDENTITY (1, 1) NOT NULL,
    [FarmID]       INT             NOT NULL,
    [ManureTypeID] INT             NOT NULL,
    [ManureTypeName] NVARCHAR (250)    NULL,
    [FieldTypeID]  INT             NOT NULL,
    [DryMatter]    DECIMAL (18, 2) NOT NULL,
    [TotalN]       DECIMAL (18, 2) NOT NULL,
    [NH4N]         DECIMAL (18, 2) NOT NULL,
    [Uric]         DECIMAL (18, 2) NOT NULL,
    [NO3N]         DECIMAL (18, 2) NOT NULL,
    [P2O5]         DECIMAL (18, 2) NOT NULL,
    [K2O]          DECIMAL (18, 2) NOT NULL,
    [SO3]          DECIMAL (18, 2) NOT NULL,
    [MgO]          DECIMAL (18, 2) NOT NULL,
    [CreatedOn]    DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [CreatedByID]  INT             NULL,
    [ModifiedOn]   DATETIME2 (7)   NULL,
    [ModifiedByID] INT             NULL,
    CONSTRAINT [PK_FarmManureTypes] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FarmManureTypes_Farms] FOREIGN KEY ([FarmID]) REFERENCES [dbo].[Farms] ([ID]),
    CONSTRAINT [FK_FarmManureTypes_Users_CreatedBy] FOREIGN KEY ([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_FarmManureTypes_Users_ModifiedBy] FOREIGN KEY ([ModifiedByID]) REFERENCES [dbo].[Users] ([ID])
);


