﻿/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


IF NOT EXISTS (SELECT 1 FROM [dbo].[Countries])
BEGIN
    SET IDENTITY_INSERT [dbo].[Countries] ON
    INSERT INTO [Countries] (ID,Name,RB209CountryID) values(1,'England',1)
    INSERT INTO [Countries] (ID,Name,RB209CountryID) values(2,'Scotland',2)
    INSERT INTO [Countries] (ID,Name,RB209CountryID) values(3,'Wales',1)
    SET IDENTITY_INSERT [dbo].[Countries] OFF
END



IF NOT EXISTS (SELECT 1 FROM [dbo].[SoilTypeSoilTextures])
BEGIN
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (0, 3, 2)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (1, 3, 16)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (2, 3, 8)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (3, 9, 12)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (4, 6, 6)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (5, 13, 12)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (6, 15, 15)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (10, 2, 2)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (11, 3, 17)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (12, 3, 3)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (13, 8, 8)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (14, 13, 13)
INSERT [dbo].[SoilTypeSoilTextures] ([SoilTypeID], [TopSoilID], [SubSoilID]) VALUES (15, 14, 14)
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[SNSCategories])
BEGIN
SET IDENTITY_INSERT [dbo].[SNSCategories] ON 
INSERT [dbo].[SNSCategories] ([ID], [Name]) VALUES (1, N'Other arable/potatoes')
INSERT [dbo].[SNSCategories] ([ID], [Name]) VALUES (2, N'Winter oilseed rape')
INSERT [dbo].[SNSCategories] ([ID], [Name]) VALUES (3, N'Winter cereals')
INSERT [dbo].[SNSCategories] ([ID], [Name]) VALUES (4, N'Vegetables')
INSERT [dbo].[SNSCategories] ([ID], [Name]) VALUES (5, N'Fruit')
SET IDENTITY_INSERT [dbo].[SNSCategories] OFF
END

GO


SET IDENTITY_INSERT [dbo].[CropInfoQuestions] ON 

IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 1)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (1, N'How do you plan to use the grain?')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 2)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (2, N'Will you harvest and remove both the seed and straw?')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 3)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (3, N'How will you use it?')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 4)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (4, N'Will you harvest and remove both the roots and tops?')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 5)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (5, N'Is this the establishment year?')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 6)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (6, N'Select the type of cabbage')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 7)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (7, N'Select the type of cauliflower')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 8)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (8, N'When will you sow this crop?')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 9)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (9, N'Select current orchard management')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 10)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (10, N'Select crop stage')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 11)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (11, N'Select crop stage and type (for established crops)')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 12)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (12, N'Select the length of growing season')
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[CropInfoQuestions] WHERE [ID] = 13)
BEGIN
    INSERT [dbo].[CropInfoQuestions] ([ID], [CropInfoQuestion]) VALUES (13, N'Is the crop in its first two years of establishment?')
END

SET IDENTITY_INSERT [dbo].[CropInfoQuestions] OFF


IF NOT EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings])
BEGIN
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (0, 2, CAST(8.0 AS Decimal(18, 1)), 0, 220,220, 3,1)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (1, 2, CAST(6.5 AS Decimal(18, 1)), 0, 180,180, 3,1)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (2, 6, CAST(6.0 AS Decimal(18, 1)), 0, 180,180, 1,1)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (3, 6, CAST(5.5 AS Decimal(18, 1)), 0, 150,150, 1,1)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (4, 2, CAST(6.0 AS Decimal(18, 1)), 0, NULL,NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (5, 6, CAST(6.0 AS Decimal(18, 1)), 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (6, 2, CAST(6.0 AS Decimal(18, 1)), 0, NULL,NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (7, 6, CAST(6.0 AS Decimal(18, 1)), 0, NULL,NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (8, 2, CAST(8.0 AS Decimal(18, 1)), 0, NULL,NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (9, 6, CAST(6.0 AS Decimal(18, 1)), 0, NULL,NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (20, 4, CAST(3.5 AS Decimal(18, 1)), 0, 250,250, 2,2)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (21, 6, NULL, 0, NULL,NULL, 1,2)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (22, 9, NULL, 0, NULL,NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (23, 9, CAST(4.0 AS Decimal(18, 1)), 0, 0,0, 1,3)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (24, 9, CAST(3.5 AS Decimal(18, 1)), 0, 0, 0,1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (25, 9, CAST(3.5 AS Decimal(18, 1)), 0, 0, 0,1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (26, 8, CAST(60.0 AS Decimal(18, 1)), 0, 120,120, 1,4)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (27, 9, NULL, 1, NULL,NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (28, 9, NULL, 0, NULL,NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (40, 9, NULL, 0, 150,150, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (41, 9, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (43, 9, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (44, 9, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (45, 9, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (50, 6, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (51, 6, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (52, 2, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (53, 2, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (54, 6, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (55, 6, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (56, 6, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (57, 2, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (58, 2, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (59, 2, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (60, 9, NULL, 1, 180, 150, 4,5)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (61, 9, NULL, 0, 370, 350, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (62, 9, NULL, 0, 370, 350, 4,6)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (63, 9, NULL, 0, 370, 350, 4,7)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (64, 9, NULL, 0, 370, 350, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (65, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (66, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (67, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (68, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (69, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (70, 9, NULL, 0, 180, 150, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (71, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (72, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (73, 9, NULL, 0, 280, 250, 4,8)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (74, 9, NULL, 0, 280, 250, 4,8)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (75, 9, NULL, 0, 370, 350, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (76, 9, NULL, 1, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (77, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (78, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (79, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (90, 8, NULL, 0, 370, 350, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (91, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (92, 9, NULL, 0, 180, 150, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (93, 9, NULL, 0, 280, 250, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (94, 9, NULL, 0, 180, 150, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (110, 9, NULL, 1, NULL, NULL, 5,9)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (111, 9, NULL, 1, NULL, NULL, 5,9)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (112, 9, NULL, 1, NULL, NULL, 5,9)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (113, 9, NULL, 1, NULL, NULL, 5,9)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (114, 9, NULL, 1, NULL, NULL, 5,9)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (115, 9, NULL, 1, NULL, NULL, 5,9)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (116, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (117, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (118, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (119, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (120, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (121, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (122, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (123, 9, NULL, 1, NULL, NULL, 5,11)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (124, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (125, 9, NULL, 1, NULL, NULL, 5,10)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (140, 1, NULL, 0, 300,300, NULL,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (160, 7, CAST(50.0 AS Decimal(18, 1)), 0, 270, 270, 1,12)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (161, 7, CAST(50.0 AS Decimal(18, 1)), 0, 270, 270, 1,12)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (162, 7, CAST(50.0 AS Decimal(18, 1)), 0, 270, 270, 1,12)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (163, 7, CAST(50.0 AS Decimal(18, 1)), 0, 270, 270, 1,12)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (170, 9, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (171, 6, NULL, 0, NULL, NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (172, 6, NULL, 0, NULL, NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (173, 6, NULL, 0, NULL, NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (174, 6, NULL, 0, NULL, NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (175, 9, NULL, 0, NULL, NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (176, 9, NULL, 0, NULL, NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (177, 9, NULL, 1, NULL, NULL, NULL,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (178, 9, NULL, 1, NULL, NULL, NULL,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (179, 9, NULL, 1, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (180, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (181, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (182, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (184, 9, NULL, 1, NULL, NULL, 1,13)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (185, 9, NULL, 1, NULL, NULL, 1,5)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (187, 9, NULL, 1, NULL, NULL, 3,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (188, 9, NULL, 0, NULL, NULL, NULL,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (189, 9, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (191, 9, NULL, 0, NULL, NULL, NULL,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (192, 9, NULL, 0, NULL, NULL, 4,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (193, 9, NULL, 1, NULL, NULL, 4,5)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (194, 9, NULL, 0, NULL, NULL, 1,NULL)
INSERT [dbo].[CropTypeLinkings] ([CropTypeID], [MannerCropTypeID], [DefaultYield], [IsPerennial], [NMaxLimitEngland], [NMaxLimitWales], [SNSCategoryID],[CropInfoOneQuestionID]) VALUES (195, 9, NULL, 0, NULL, NULL, 1,NULL)
END
GO


IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=0)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=220,[NMaxLimitWales]=220 where [CropTypeID]=0
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=1)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=180,[NMaxLimitWales]=180 where [CropTypeID]=1
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=2)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=180,[NMaxLimitWales]=180 where [CropTypeID]=2
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=3)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=150,[NMaxLimitWales]=150 where [CropTypeID]=3
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=20)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=250,[NMaxLimitWales]=250 where [CropTypeID]=20
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=23)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=0,[NMaxLimitWales]=0 where [CropTypeID]=23
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=24)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=0,[NMaxLimitWales]=0 where [CropTypeID]=24
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=25)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=0,[NMaxLimitWales]=0 where [CropTypeID]=25
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=26)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=120,[NMaxLimitWales]=120 where [CropTypeID]=26
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=40)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=150,[NMaxLimitWales]=150 where [CropTypeID]=40
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=60)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=180,[NMaxLimitWales]=150 where [CropTypeID]=60
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=61)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=370,[NMaxLimitWales]=350 where [CropTypeID]=61
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=62)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=370,[NMaxLimitWales]=350 where [CropTypeID]=62
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=63)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=370,[NMaxLimitWales]=350 where [CropTypeID]=63
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=64)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=370,[NMaxLimitWales]=350 where [CropTypeID]=64
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=65)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=65
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=67)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=67
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=68)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=68
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=69)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=69
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=70)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=180,[NMaxLimitWales]=150 where [CropTypeID]=70
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=71)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=71
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=72)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=72
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=73)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=73
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=74)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=74
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=75)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=370,[NMaxLimitWales]=350 where [CropTypeID]=75
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=90)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=370,[NMaxLimitWales]=350 where [CropTypeID]=90
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=91)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=91
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=92)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=180,[NMaxLimitWales]=150 where [CropTypeID]=92
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=93)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=280,[NMaxLimitWales]=250 where [CropTypeID]=93
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=94)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=180,[NMaxLimitWales]=150 where [CropTypeID]=94
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=140)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=300,[NMaxLimitWales]=300 where [CropTypeID]=140
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=160)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=270,[NMaxLimitWales]=270 where [CropTypeID]=160
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=161)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=270,[NMaxLimitWales]=270 where [CropTypeID]=161
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=162)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=270,[NMaxLimitWales]=270 where [CropTypeID]=162
END
IF EXISTS (SELECT 1 FROM [dbo].[CropTypeLinkings] where [CropTypeID]=163)
BEGIN
UPDATE [dbo].[CropTypeLinkings] SET [NMaxLimitEngland]=270,[NMaxLimitWales]=270 where [CropTypeID]=163
END



IF NOT EXISTS (SELECT 1 FROM [dbo].[InOrganicManureDurations])
BEGIN
    SET IDENTITY_INSERT [dbo].[InOrganicManureDurations] ON 
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (1, N'August to September', 1, 9)
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (2, N'October to December', 15, 11)
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (3, N'January to mid February', 23, 1)
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (4, N'Mid February to early March', 1, 3)
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (5, N'Mid March to early April', 1, 4)
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (6, N'Mid April to early May', 1, 5)
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (7, N'Mid May to early June', 1, 6)
    INSERT [dbo].[InOrganicManureDurations] ([ID], [Name], [ApplicationDate], [ApplicationMonth]) VALUES (8, N'Mid June to July', 7, 7)
    SET IDENTITY_INSERT [dbo].[InOrganicManureDurations] OFF
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[SecondCropLinkings])
BEGIN
--SET IDENTITY_INSERT [dbo].[SecondCropLinkings] ON

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (0, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (0, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (1, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (1, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (2, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (2, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (3, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (3, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (4, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (4, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (5, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (5, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (6, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (6, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (7, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (7, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (8, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (8, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (9, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (9, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 2)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 3)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 5)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 7)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 9)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 23)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 24)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 25)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 171)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 172)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 173)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (55, 174)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 2)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 3)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 5)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 7)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 9)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 23)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 24)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 25)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 40)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 44)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 45)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 171)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 172)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 173)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (58, 174)



INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (60, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (61, 182)


INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (62, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (63, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (64, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (65, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (66, 182)


INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (67, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (68, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (69, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (70, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (71, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (72, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 182)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (73, 181)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (74, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (75, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (77, 182)


INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (78, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (79, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (90, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (91, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (92, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (93, 182)


INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (94, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 2)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 3)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 5)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 7)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 9)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 23)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 24)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 25)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 40)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 45)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 44)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 171)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 172)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 173)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 174)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 188)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (140, 189)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (170, 170)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (171, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (171, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (172, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (172, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (173, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (173, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (174, 43)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (174, 44)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (181, 182)

INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 60)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 61)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 62)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 63)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 64)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 65)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 66)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 67)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 68)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 69)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 70)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 71)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 72)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 73)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 74)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 75)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 77)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 78)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 79)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 90)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 91)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 92)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 93)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 94)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 170)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 181)
INSERT [dbo].[SecondCropLinkings] ([FirstCropID], [SecondCropID]) VALUES (182, 182)
--SET IDENTITY_INSERT [dbo].[SecondCropLinkings] OFF
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[GrassManagementOptions])
BEGIN
    SET IDENTITY_INSERT [dbo].[GrassManagementOptions] ON 
    INSERT [dbo].[GrassManagementOptions] ([ID], [Name]) VALUES (1, N'Cut only')
    INSERT [dbo].[GrassManagementOptions] ([ID], [Name]) VALUES (2, N'Grazed only')
    INSERT [dbo].[GrassManagementOptions] ([ID], [Name]) VALUES (3, N'Grazed and cut')
    SET IDENTITY_INSERT [dbo].[GrassManagementOptions] OFF
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[GrassTypicalCuts])
BEGIN
    SET IDENTITY_INSERT [dbo].[GrassTypicalCuts] ON 
    INSERT [dbo].[GrassTypicalCuts] ([ID], [Name]) VALUES (1, N'One')
    INSERT [dbo].[GrassTypicalCuts] ([ID], [Name]) VALUES (2, N'Two or more')
    SET IDENTITY_INSERT [dbo].[GrassTypicalCuts] OFF
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[SoilNitrogenSupplyItems])
BEGIN
SET IDENTITY_INSERT [dbo].[SoilNitrogenSupplyItems] ON 
INSERT [dbo].[SoilNitrogenSupplyItems] ([ID], [Name],[SoilNitrogenSupplyId]) VALUES (1, N'None',1)
INSERT [dbo].[SoilNitrogenSupplyItems] ([ID], [Name],[SoilNitrogenSupplyId]) VALUES (2, N'Up to 100kg per hectare',1)
INSERT [dbo].[SoilNitrogenSupplyItems] ([ID], [Name],[SoilNitrogenSupplyId]) VALUES (3, N'100kg to 250kg per hectare',2)
INSERT [dbo].[SoilNitrogenSupplyItems] ([ID], [Name],[SoilNitrogenSupplyId]) VALUES (4, N'Over 250kg per hectare',3)
    
SET IDENTITY_INSERT [dbo].[SoilNitrogenSupplyItems] OFF
END

IF EXISTS (SELECT 1 FROM [dbo].[Farms] where [ClimateDataPostCode] IS NULL)
BEGIN
UPDATE [dbo].[Farms] SET [ClimateDataPostCode]=[Postcode] where [ClimateDataPostCode] IS NULL
END


IF NOT EXISTS (SELECT 1 FROM [dbo].[ExcessWinterRainfallOptions])
BEGIN
    SET IDENTITY_INSERT [dbo].[ExcessWinterRainfallOptions] ON
    INSERT [dbo].[ExcessWinterRainfallOptions] ([ID], [Name], [Value]) VALUES (1, N'High - 250mm or more', 300)
	INSERT [dbo].[ExcessWinterRainfallOptions] ([ID], [Name], [Value]) VALUES (2, N'Moderate - 150mm to 250mm', 200)
	INSERT [dbo].[ExcessWinterRainfallOptions] ([ID], [Name], [Value]) VALUES (3, N'Low - Less than 150mm', 100)
    SET IDENTITY_INSERT [dbo].[ExcessWinterRainfallOptions] OFF
END


GO