CREATE PROCEDURE [dbo].[spFarms_DeleteFarmAndRelatedEntities]
@FarmID INT
AS
BEGIN
 
-- Use temporary tables to store intermediate results
DECLARE @FieldIDs TABLE (ID INT);
DECLARE @CropIDs TABLE (ID INT);
DECLARE @ManagementPeriodIDs TABLE (ID INT);
DECLARE @RecommendationIDs TABLE (ID INT);
DECLARE @FarmManureTypeIDs TABLE (ID INT); -- New table to store FarmManureType IDs
 
BEGIN TRY
BEGIN TRANSACTION;
 
-- Fetch and store Field IDs
INSERT INTO @FieldIDs (ID)
SELECT ID FROM Fields WHERE FarmID = @FarmID;
 
-- Fetch and store Crop IDs
INSERT INTO @CropIDs (ID)
SELECT ID FROM Crops WHERE FieldID IN (SELECT ID FROM @FieldIDs);
 
-- Fetch and store ManagementPeriod IDs
INSERT INTO @ManagementPeriodIDs (ID)
SELECT ID FROM ManagementPeriods WHERE CropID IN (SELECT ID FROM @CropIDs);
 
-- Fetch and store Recommendation IDs
INSERT INTO @RecommendationIDs (ID)
SELECT ID FROM Recommendations WHERE ManagementPeriodID IN (SELECT ID FROM @ManagementPeriodIDs);
 
-- Fetch and store FarmManureType IDs
INSERT INTO @FarmManureTypeIDs (ID)
SELECT ID FROM FarmManureTypes WHERE FarmID = @FarmID;
 
-- Delete related RecommendationComments
DELETE FROM RecommendationComments
WHERE RecommendationID IN (SELECT ID FROM @RecommendationIDs);
 
-- Delete related Recommendations
DELETE FROM Recommendations
WHERE ID IN (SELECT ID FROM @RecommendationIDs);
 
-- Delete related OrganicManures
DELETE FROM OrganicManures
WHERE ManagementPeriodID IN (SELECT ID FROM @ManagementPeriodIDs);
 
-- Delete related SoilAnalyses
DELETE FROM SoilAnalyses
WHERE FieldID IN (SELECT ID FROM @FieldIDs);
 
-- Delete related FarmManureTypes
DELETE FROM FarmManureTypes
WHERE ID IN (SELECT ID FROM @FarmManureTypeIDs);
 
-- Delete related ManagementPeriods
DELETE FROM ManagementPeriods
WHERE ID IN (SELECT ID FROM @ManagementPeriodIDs);
 
-- Delete related Crops
DELETE FROM Crops
WHERE ID IN (SELECT ID FROM @CropIDs);
 
-- Delete related Fields
DELETE FROM Fields WHERE ID IN (SELECT ID FROM @FieldIDs);
 
-- Delete the Farm
DELETE FROM Farms WHERE ID = @FarmID;
 
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
DECLARE @ErrorMessage NVARCHAR(MAX);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
 
SELECT
@ErrorMessage = ERROR_MESSAGE(),
@ErrorSeverity = ERROR_SEVERITY(),
@ErrorState = ERROR_STATE();
 
RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
END;
GO