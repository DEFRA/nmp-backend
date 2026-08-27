CREATE TABLE [dbo].[SecondCropLinkings] (
    [FirstCropID]    INT NOT NULL,
    [SecondCropID]   INT NOT NULL,
    [RB209CountryID] INT NOT NULL DEFAULT 3,
    CONSTRAINT [PK_SecondCropLinkings] PRIMARY KEY CLUSTERED ([FirstCropID] ASC, [SecondCropID] ASC)
);

