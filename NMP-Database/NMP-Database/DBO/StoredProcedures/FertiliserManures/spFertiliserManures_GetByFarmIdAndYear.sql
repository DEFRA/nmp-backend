CREATE PROCEDURE [dbo].[spFertiliserManures_GetByFarmIdAndYear]
	@farmId int,
	@harvestYear int
AS
	SELECT fi.ID ID,fi.[Name] [Name],CONVERT(DATE,fert.ApplicationDate) ApplicationDate,fert.ID AS FertiliserId,
fert.N Nitrogen,fert.P2O5 P2O5,fert.MgO MgO,fert.K2O K2O, fert.Lime Lime,fert.SO3 SO3,fert.ManagementPeriodID AS ManagementPeriodID
FROM FertiliserManures as fert
INNER JOIN ManagementPeriods AS m ON m.ID=fert.ManagementPeriodID
INNER JOIN Crops AS c ON c.ID=m.CropID
INNER JOIN Fields AS fi ON fi.ID=c.FieldID
INNER JOIN Farms AS fa ON fa.ID=fi.FarmID
WHERE fa.ID=@farmId and c.[Year]=@harvestYear
RETURN 0
