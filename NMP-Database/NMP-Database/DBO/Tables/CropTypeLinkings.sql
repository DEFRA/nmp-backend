CREATE TABLE [dbo].[CropTypeLinkings] (
    [CropTypeID]       INT NOT NULL,
    [MannerCropTypeID] INT NOT NULL
    CONSTRAINT [PK_CropTypeLinkings] PRIMARY KEY CLUSTERED ([CropTypeID],[MannerCropTypeID] ASC),
    CONSTRAINT [FK_CropTypeLinkings_MannerCropTypes_MannerCropTypeID] FOREIGN KEY ([MannerCropTypeID]) REFERENCES [dbo].[MannerCropTypes] ([ID])

);

