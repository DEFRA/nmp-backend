CREATE TABLE [dbo].[SecondCropLinkings]
(
   [FirstCropID] INT NOT NULL, 
   [SecondCropID] INT NOT NULL,
   CONSTRAINT PK_SecondCropLinkings PRIMARY KEY CLUSTERED (FirstCropID, SecondCropID)
)
