CREATE PROCEDURE [dbo].[spRecommendationComments_DeleteRecommendationComments]
    @RecommendationCommentsID INT
AS
BEGIN
    DELETE FROM RecommendationComments
    WHERE ID = @RecommendationCommentsID;
END;
GO