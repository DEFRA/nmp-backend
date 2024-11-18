CREATE TABLE [dbo].[PKBalances]
(
    [ID]     INT IDENTITY(1,1) NOT NULL,
    [Year]   INT NOT NULL, 
    [FieldID] INT NOT NULL, 
    [PBalance] INT NOT NULL CONSTRAINT DF_PKBalances_PBalance DEFAULT 0, 
    [KBalance] INT NOT NULL CONSTRAINT DF_PKBalances_KBalance DEFAULT 0,  
    [CreatedOn]             DATETIME2     NOT  NULL DEFAULT GETDATE(), 
    [CreatedByID]           INT           NOT  NULL, 
    [ModifiedOn]            DATETIME2       NULL, 
    [ModifiedByID]          INT             NULL,
    [PreviousID]  INT NULL,    
    CONSTRAINT [PK_PKBalances] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PKBalances_Fields] FOREIGN KEY([FieldID]) REFERENCES [dbo].[Fields] ([ID]),
    CONSTRAINT [FK_PKBalances_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_PKBalances_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID]),
)
