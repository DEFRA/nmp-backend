CREATE TABLE [dbo].[CropTypeLinkings] (
    [CropTypeID]       INT NOT NULL,
    [MannerCropTypeID] INT NOT NULL
    CONSTRAINT [PK_CropTypeLinkings] PRIMARY KEY CLUSTERED ([CropTypeID],[MannerCropTypeID] ASC),
    [DefaultYield] DECIMAL(18, 1) NULL,
    [IsPerennial] BIT NOT NULL, 
    [NMaxLimit]   INT NULL,
    CONSTRAINT [FK_CropTypeLinkings_MannerCropTypes] FOREIGN KEY ([MannerCropTypeID]) REFERENCES [dbo].[MannerCropTypes] ([ID])

);

