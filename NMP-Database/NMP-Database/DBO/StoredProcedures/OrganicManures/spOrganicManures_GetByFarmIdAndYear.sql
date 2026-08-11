CREATE PROCEDURE [dbo].[spOrganicManures_GetByFarmIdAndYear]
	@farmId int,
	@harvestYear int
AS
	SELECT fi.ID,fi.[Name] [Name],CONVERT(DATE,OrganicManures.ApplicationDate) ApplicationDate,OrganicManures.ID AS OrganicManureId,
OrganicManures.N Nitrogen,OrganicManures.P2O5 P2O5,OrganicManures.MgO MgO,OrganicManures.K2O K2O,OrganicManures.SO3 SO3,
OrganicManures.DryMatterPercent AS DryMatterPercent,OrganicManures.NH4N AS NH4N,OrganicManures.NO3N AS NO3N,
OrganicManures.UricAcid AS UricAcid,
OrganicManures.ManureTypeID AS
ManureTypeID,OrganicManures.ManagementPeriodID AS ManagementPeriodID
FROM OrganicManures 
INNER JOIN ManagementPeriods AS m ON m.ID=OrganicManures.ManagementPeriodID
INNER JOIN Crops AS c ON c.ID=m.CropID
INNER JOIN Fields AS fi ON fi.ID=c.FieldID
INNER JOIN Farms AS fa ON fa.ID=fi.FarmID
WHERE fa.ID=@farmId and c.[Year]=@harvestYear
RETURN 0