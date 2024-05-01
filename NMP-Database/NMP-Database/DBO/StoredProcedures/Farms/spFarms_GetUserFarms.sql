CREATE PROCEDURE [dbo].[spFarms_GetUserFarms]
    @userID INT,
    @shortSummary BIT = 0
AS
BEGIN
    IF @shortSummary = 1
    BEGIN
        SELECT 
            [Farms].[ID],
            [Farms].[Name]
        FROM 
            [UserFarms]
        LEFT JOIN 
            [Farms] ON [Farms].ID = [UserFarms].[FarmID]
        WHERE 
            [UserFarms].[UserID] = @userID
        ORDER BY [Farms].[Name];
    END
    ELSE 
    BEGIN
        SELECT 
            [Farms].[ID],
            [Farms].[Name],
            [Farms].[Address1],
            [Farms].[Address2],
            [Farms].[Address3],
            [Farms].[Address4],
            [Farms].[Postcode],
            [Farms].[CPH],
            [Farms].[FarmerName],
            [Farms].[BusinessName],
            [Farms].[SBI],
            [Farms].[STD],
            [Farms].[Telephone],
            [Farms].[Mobile],
            [Farms].[Email],
            [Farms].[Rainfall],
            [Farms].[TotalFarmArea],
            [Farms].[AverageAltitude],
            [Farms].[RegisteredOrganicProducer],
            [Farms].[MetricUnits],
            [Farms].[EnglishRules],
            [Farms].[NVZFields],
            [Farms].[FieldsAbove300SeaLevel]
        FROM 
            [UserFarms]
        LEFT JOIN 
            [Farms] ON [Farms].ID = [UserFarms].[FarmID]
        WHERE 
            [UserFarms].[UserID] = @userID
        ORDER BY [Farms].[Name];
    END
END