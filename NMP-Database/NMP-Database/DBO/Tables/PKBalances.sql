CREATE TABLE [dbo].[PKBalances]
(
    [ID]     INT IDENTITY(1,1) NOT NULL,
    [Year]   INT NOT NULL, 
    [FieldID] INT NOT NULL, 
    [PBalance] INT NOT NULL CONSTRAINT DF_PKBalances_PBalance DEFAULT 0, 
    [KBalance] INT NOT NULL CONSTRAINT DF_PKBalances_KBalance DEFAULT 0,  
    [PreviousID]  INT NULL,    
    CONSTRAINT [PK_PKBalances] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PKBalances_Fields] FOREIGN KEY([FieldID]) REFERENCES [dbo].[Fields] ([ID]),
)
