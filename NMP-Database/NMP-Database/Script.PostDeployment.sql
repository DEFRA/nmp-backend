/*
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


IF NOT EXISTS (SELECT 1 FROM [dbo].[Users])
BEGIN
SET IDENTITY_INSERT [dbo].[Users] ON 
INSERT [dbo].[Users] ([ID], [GivenName], [SurName], [Email], [UserName]) VALUES (1, N'NMPTUser', NULL, N'mark.brown@rsk-bsl.com', N'609CB6D5-7185-4C1F-95F1-DB09567B15C2')
SET IDENTITY_INSERT [dbo].[Users] OFF
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles])
BEGIN
SET IDENTITY_INSERT [dbo].[Roles] ON 
INSERT [dbo].[Roles] ([ID], [Name]) VALUES (1, N'Farmer')
INSERT [dbo].[Roles] ([ID], [Name]) VALUES (2, N'Agronomist / Advisor')
INSERT [dbo].[Roles] ([ID], [Name]) VALUES (3, N'Agent')
SET IDENTITY_INSERT [dbo].[Roles] OFF
END