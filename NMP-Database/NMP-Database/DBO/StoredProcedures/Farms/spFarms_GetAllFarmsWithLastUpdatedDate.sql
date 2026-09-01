CREATE PROCEDURE [dbo].[spFarms_GetAllFarmsWithLastUpdatedDate]
(
@OrganisationID UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        F.ID,
        F.Name,
        LU.LastUpdatedDate AS ModifiedOn
    FROM Farms F
    OUTER APPLY
    (
        SELECT MAX(LastUpdatedDate) AS LastUpdatedDate
        FROM
        (
            -- Farm
            SELECT COALESCE(F.ModifiedOn, F.CreatedOn)

            UNION ALL

            -- Fields
            SELECT MAX(COALESCE(FL.ModifiedOn, FL.CreatedOn))
            FROM Fields FL
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- Crops
            SELECT MAX(COALESCE(C.ModifiedOn, C.CreatedOn))
            FROM Crops C
            INNER JOIN Fields FL ON FL.ID = C.FieldID
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- ManagementPeriods
            SELECT MAX(COALESCE(MP.ModifiedOn, MP.CreatedOn))
            FROM ManagementPeriods MP
            INNER JOIN Crops C ON C.ID = MP.CropID
            INNER JOIN Fields FL ON FL.ID = C.FieldID
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- Recommendations
            SELECT MAX(COALESCE(R.ModifiedOn, R.CreatedOn))
            FROM Recommendations R
            INNER JOIN ManagementPeriods MP ON MP.ID = R.ManagementPeriodID
            INNER JOIN Crops C ON C.ID = MP.CropID
            INNER JOIN Fields FL ON FL.ID = C.FieldID
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- OrganicManures
            SELECT MAX(COALESCE(OM.ModifiedOn, OM.CreatedOn))
            FROM OrganicManures OM
            INNER JOIN ManagementPeriods MP ON MP.ID = OM.ManagementPeriodID
            INNER JOIN Crops C ON C.ID = MP.CropID
            INNER JOIN Fields FL ON FL.ID = C.FieldID
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- FertiliserManures
            SELECT MAX(COALESCE(FM.ModifiedOn, FM.CreatedOn))
            FROM FertiliserManures FM
            INNER JOIN ManagementPeriods MP ON MP.ID = FM.ManagementPeriodID
            INNER JOIN Crops C ON C.ID = MP.CropID
            INNER JOIN Fields FL ON FL.ID = C.FieldID
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- SoilAnalyses
            SELECT MAX(COALESCE(SA.ModifiedOn, SA.CreatedOn))
            FROM SoilAnalyses SA
            INNER JOIN Fields FL ON FL.ID = SA.FieldID
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- FarmManureTypes
            SELECT MAX(COALESCE(FMT.ModifiedOn, FMT.CreatedOn))
            FROM FarmManureTypes FMT
            WHERE FMT.FarmID = F.ID

            UNION ALL

            -- WarningMessages
            SELECT MAX(COALESCE(WM.ModifiedOn, WM.CreatedOn))
            FROM WarningMessages WM
            INNER JOIN Fields FL ON FL.ID = WM.FieldID
            WHERE FL.FarmID = F.ID

            UNION ALL

            -- NutrientsLoadingFarmDetails
            SELECT MAX(COALESCE(NLFD.ModifiedOn, NLFD.CreatedOn))
            FROM NutrientsLoadingFarmDetails NLFD
            WHERE NLFD.FarmID = F.ID

            UNION ALL

            -- NutrientsLoadingManures
            SELECT MAX(COALESCE(NLM.ModifiedOn, NLM.CreatedOn))
            FROM NutrientsLoadingManures NLM
            WHERE NLM.FarmID = F.ID

            UNION ALL

            -- NutrientsLoadingLiveStocks
            SELECT MAX(COALESCE(NLS.ModifiedOn, NLS.CreatedOn))
            FROM NutrientsLoadingLiveStocks NLS
            WHERE NLS.FarmID = F.ID

            UNION ALL

            -- StoreCapacities
            SELECT MAX(COALESCE(SC.ModifiedOn, SC.CreatedOn))
            FROM StoreCapacities SC
            WHERE SC.FarmID = F.ID

            UNION ALL

            -- FarmAverageYields
            SELECT MAX(COALESCE(FAY.ModifiedOn, FAY.CreatedOn))
            FROM FarmAverageYields FAY
            WHERE FAY.FarmID = F.ID

            UNION ALL

            -- FarmsNVZ
            SELECT MAX(COALESCE(FNVZ.ModifiedOn, FNVZ.CreatedOn))
            FROM FarmsNVZ FNVZ
            WHERE FNVZ.FarmID = F.ID

            UNION ALL

            -- ExcessRainfalls
            SELECT MAX(COALESCE(ER.ModifiedOn, ER.CreatedOn))
            FROM ExcessRainfalls ER
            WHERE ER.FarmID = F.ID

        ) Updates(LastUpdatedDate)
    ) LU
    WHERE F.OrganisationID = @OrganisationID
    ORDER BY LU.LastUpdatedDate DESC;
END
GO