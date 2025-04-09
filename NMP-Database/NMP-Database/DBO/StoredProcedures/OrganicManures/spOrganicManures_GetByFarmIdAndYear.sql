CREATE PROCEDURE [dbo].[spOrganicManures_GetByFarmIdAndYear]
	@farmId int,
	@harvestYear int
AS
	SELECT fi.id ID,fi.[Name] [Name],CONVERT(DATE,OrganicManures.ApplicationDate) ApplicationDate,OrganicManures.ID AS OrganicManureId,
OrganicManures.N Nitrogen,OrganicManures.P2O5 P2O5,OrganicManures.MgO MgO,OrganicManures.K2O K2O,OrganicManures.SO3 SO3,
OrganicManures.DryMatterPercent AS DryMatterPercent,OrganicManures.NH4N AS NH4N,OrganicManures.NO3N AS NO3N,
OrganicManures.UricAcid AS UricAcid,
OrganicManures.ManureTypeID AS
ManureTypeID,OrganicManures.ManagementPeriodID AS ManagementPeriodID
FROM OrganicManures 
INNER JOIN ManagementPeriods AS m ON m.id=OrganicManures.ManagementPeriodID
INNER JOIN Crops AS c ON c.id=m.CropID
INNER JOIN Fields AS fi ON fi.id=c.FieldID
INNER JOIN Farms AS fa ON fa.id=fi.FarmID
WHERE fa.id=@farmId and c.[year]=@harvestYear
RETURN 0