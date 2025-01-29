CREATE TABLE [dbo].[CropTypeLinkings] (
    [CropTypeID]       INT             NOT NULL,
    [MannerCropTypeID] INT             NOT NULL,
    [DefaultYield]     DECIMAL (18, 1) NULL,
    [IsPerennial]      BIT             NOT NULL,
    [NMaxLimitEngland] INT             NULL,
    [NMaxLimitWales]   INT             NULL,
    [SNSCategoryID]    INT             NULL,
    [CropInfoOneQuestionID] INT          NULL, 
    CONSTRAINT [PK_CropTypeLinkings] PRIMARY KEY CLUSTERED ([CropTypeID] ASC, [MannerCropTypeID] ASC),
    CONSTRAINT [FK_CropTypeLinkings_SNSCategories] FOREIGN KEY ([SNSCategoryID]) REFERENCES [dbo].[SNSCategories] ([ID]),
    CONSTRAINT [FK_CropTypeLinkings_CropInfoQuestions] FOREIGN KEY ([CropInfoOneQuestionID]) REFERENCES [dbo].[CropInfoQuestions] ([ID])
);



