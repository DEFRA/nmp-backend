CREATE TABLE [dbo].[RecommendationComments] (
    [ID]                    INT NOT NULL IDENTITY (1, 1) ,
    [RecommendationID]      INT NOT NULL,
    [Nutrient]              INT NOT NULL CONSTRAINT DF_RecommendationComments_Nutrient DEFAULT (0),
    [Comment]               NVARCHAR (MAX) NULL,
    [CreatedOn]             DATETIME2      NULL DEFAULT GETDATE(), 
    [CreatedByID]           INT            NULL, 
    [ModifiedOn]            DATETIME2      NULL, 
    [ModifiedByID]          INT            NULL,
    [PreviousID]            INT NULL           
    CONSTRAINT [PK_RecommendationComments] PRIMARY KEY CLUSTERED([ID] ASC),    
    CONSTRAINT [FK_RecommendationComments_Recommendations] FOREIGN KEY( [RecommendationID] ) REFERENCES [dbo].[Recommendations] ([ID]),
    CONSTRAINT [FK_RecommendationComments_Users_CreatedBy] FOREIGN KEY([CreatedByID]) REFERENCES [dbo].[Users] ([ID]),
    CONSTRAINT [FK_RecommendationComments_Users_ModifiedBy] FOREIGN KEY([ModifiedByID]) REFERENCES [dbo].[Users] ([ID]),
    
);
