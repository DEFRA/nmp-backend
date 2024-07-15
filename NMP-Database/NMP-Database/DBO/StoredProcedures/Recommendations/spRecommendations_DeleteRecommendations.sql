CREATE PROCEDURE [dbo].[spRecommendations_DeleteRecommendations]
    @RecommendationID INT
AS
BEGIN
    DECLARE @RecommendationCommentsID INT;

    -- Fetch and delete RecommendationComments
    DECLARE comment_cursor CURSOR FOR
    SELECT ID FROM RecommendationComments WHERE RecommendationID = @RecommendationID;

    OPEN comment_cursor;
    FETCH NEXT FROM comment_cursor INTO @RecommendationCommentsID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC spRecommendationComments_DeleteRecommendationComments @RecommendationCommentsID;
        FETCH NEXT FROM comment_cursor INTO @RecommendationCommentsID;
    END;

    CLOSE comment_cursor;
    DEALLOCATE comment_cursor;

    -- Delete the Recommendation
    DELETE FROM Recommendations
    WHERE ID = @RecommendationID;
END;
GO

