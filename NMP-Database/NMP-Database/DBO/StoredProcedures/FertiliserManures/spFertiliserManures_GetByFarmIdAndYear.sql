CREATE PROCEDURE [dbo].[spFertiliserManures_GetByFarmIdAndYear]
	@farmId int,
	@harvestYear int
AS
	SELECT fi.id ID,fi.[Name] [Name],CONVERT(DATE,fert.ApplicationDate) ApplicationDate,fert.ID AS FertiliserId,
fert.N Nitrogen,fert.P2O5 P2O5,fert.MgO MgO,fert.K2O K2O, fert.Lime Lime,fert.SO3 SO3,fert.ManagementPeriodID AS ManagementPeriodID
FROM FertiliserManures as fert
INNER JOIN ManagementPeriods AS m ON m.id=fert.ManagementPeriodID
INNER JOIN Crops AS c ON c.id=m.CropID
INNER JOIN Fields AS fi ON fi.id=c.FieldID
INNER JOIN Farms AS fa ON fa.id=fi.FarmID
WHERE fa.id=@farmId and c.[year]=@harvestYear
RETURN 0
