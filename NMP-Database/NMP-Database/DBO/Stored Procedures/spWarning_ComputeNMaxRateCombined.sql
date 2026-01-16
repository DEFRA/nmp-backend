






CREATE   PROCEDURE [dbo].[spWarning_ComputeNMaxRateCombined]
(
    @ManureID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- Variable declarations
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT = NULL,
        @CropID INT = NULL,
        @FieldID INT = NULL,
        @FarmID INT = NULL,
        @CountryID INT = NULL,
        @CropTypeID INT = NULL,
        @CropYear INT = NULL,
        @CropYield DECIMAL(18,3) = 0,
        @CropInfo1 INT = NULL,
        @PotentialCut DECIMAL(18,3) = 0,
        @SoilTypeID INT = NULL,
        @IsFieldWithinNVZ BIT = 0,

        @NMaxLimitEngland DECIMAL(18,3) = 0,
        @NMaxLimitWales DECIMAL(18,3) = 0,
        @DefaultYield DECIMAL(18,3) = 0,

		@BaseNMaxRate DECIMAL(18,3) = 0,
        @NMaxRate DECIMAL(18,3) = 0,
        @YieldDelta DECIMAL(18,6) = 0,
        @YieldSteps INT = 0,

        @HasPrevCurrSpecialManure BIT = 0,
        @IsCropTypeHasNMax BIT = 0,
        @IsNExceeding BIT = 0,

        @TotalOrganicN DECIMAL(18,3) = 0,
        @TotalFertiliserN DECIMAL(18,3) = 0,
        @CombinedTotalN DECIMAL(18,3) = 0,

        @IsFieldEngland BIT = 0,
        @IsFieldWales BIT = 0;


    --------------------------------------------------------------------
    -- 1) Find ManagementPeriodID (organic → fertiliser fallback)
    --------------------------------------------------------------------
    SELECT TOP (1) @ManagementPeriodID = ManagementPeriodID
    FROM OrganicManures WHERE ID = @ManureID;

    IF @ManagementPeriodID IS NULL
    BEGIN
        SELECT TOP (1) @ManagementPeriodID = ManagementPeriodID
        FROM FertiliserManures WHERE ID = @ManureID;
    END

    IF @ManagementPeriodID IS NULL
    BEGIN
        RAISERROR('ManureID not found in either OrganicManures or FertiliserManures.', 16, 1);
        RETURN;
    END


    --------------------------------------------------------------------
    -- 2) Load CropID
    --------------------------------------------------------------------
    SELECT @CropID = CropID
    FROM ManagementPeriods
    WHERE ID = @ManagementPeriodID;

    --------------------------------------------------------------------
    -- 3) Load Crop
    --------------------------------------------------------------------
    SELECT
        @FieldID      = c.FieldID,
        @CropYear     = c.Year,
        @CropTypeID   = c.CropTypeID,
        @CropYield    = ISNULL(c.Yield,0),
        @CropInfo1    = c.CropInfo1,
        @PotentialCut = ISNULL(c.PotentialCut,0)
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 4) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @FarmID     = f.FarmID,
        @IsFieldWithinNVZ = CASE WHEN f.IsWithinNVZ = 1 THEN 1 ELSE 0 END
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 5) Load Farm
    --------------------------------------------------------------------
    SELECT @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    --------------------------------------------------------------------
    -- 6) Map England & Wales
    --------------------------------------------------------------------
    SET @IsFieldEngland = CASE WHEN @CountryID = 1 THEN 1 ELSE 0 END;
    SET @IsFieldWales   = CASE WHEN @CountryID = 3 THEN 1 ELSE 0 END;


    --------------------------------------------------------------------
    -- 7) Load CropTypeLinking rules
    --------------------------------------------------------------------
    SELECT
        @NMaxLimitEngland = ISNULL(NMaxLimitEngland,0),
        @NMaxLimitWales   = ISNULL(NMaxLimitWales,0),
        @DefaultYield     = ISNULL(DefaultYield,0)
    FROM CropTypeLinkings
    WHERE CropTypeID = @CropTypeID;


    --------------------------------------------------------------------
    -- 8) Base NMaxRate
    --------------------------------------------------------------------
    IF @CountryID = 1 
        SET @BaseNMaxRate = @NMaxLimitEngland;
    ELSE IF @CountryID = 3
        SET @BaseNMaxRate = @NMaxLimitWales;
    ELSE
        SET @BaseNMaxRate = @NMaxLimitEngland;

    SET @NMaxRate = @BaseNMaxRate;
    --------------------------------------------------------------------
    -- 9) Yield-based increments
    --------------------------------------------------------------------
    IF @CropTypeID IN (0,2,1,3,20)
    BEGIN
        SET @YieldDelta = @CropYield - @DefaultYield;

        IF @YieldDelta > 0
        BEGIN
            SET @YieldSteps = FLOOR(@YieldDelta * 10);

            IF @CropTypeID = 20
                SET @NMaxRate = @NMaxRate + (@YieldSteps * 6);
            ELSE
                SET @NMaxRate = @NMaxRate + (@YieldSteps * 2);
        END
    END


    --------------------------------------------------------------------
    -- 10) SoilType increments
    --------------------------------------------------------------------
    IF @CropTypeID IN (0,53,1,52) AND @SoilTypeID = 1
        SET @NMaxRate = @NMaxRate + 20;


    --------------------------------------------------------------------
    -- 11) CropInfo1 increments
    --------------------------------------------------------------------
    IF @CropTypeID IN (0,2) AND @CropInfo1 = 2
        SET @NMaxRate = @NMaxRate + 40;


    --------------------------------------------------------------------
    -- 12) PotentialCut increment (grass)
    --------------------------------------------------------------------
    IF @CropTypeID = 140 AND @PotentialCut > 2
        SET @NMaxRate = @NMaxRate + 40;


    --------------------------------------------------------------------
    -- 13) Special manure types (33,34,40)
    --------------------------------------------------------------------
    DECLARE @PrevYear INT = @CropYear - 1;

   IF @CropTypeID IN (
     0,1,2,3,20,23,24,25,26,40,50,51,52,
	 53,60,61,62,63,64,65,67,68,69,70,71,
	 72,73,74,75,77,90,91,92,93,94,140,160,
	 161,162,163,181
)
AND EXISTS (
    SELECT 1
    FROM OrganicManures om2
    INNER JOIN ManagementPeriods mp2 ON om2.ManagementPeriodID = mp2.ID
    INNER JOIN Crops c2 ON mp2.CropID = c2.ID
    WHERE 
        c2.FieldID = @FieldID
        AND c2.Year IN (@CropYear, @PrevYear)
        AND om2.ManureTypeID IN (33,34,40)
)
BEGIN
    SET @HasPrevCurrSpecialManure = 1;
    SET @NMaxRate = @NMaxRate + 80;
END



    --------------------------------------------------------------------
    -- 14) Check if crop has NMax
    --------------------------------------------------------------------
    SET @IsCropTypeHasNMax = CASE WHEN @NMaxRate > 0 THEN 1 ELSE 0 END;


    --------------------------------------------------------------------
    -- 15) Combined Total N
    --------------------------------------------------------------------
    SELECT @TotalOrganicN =
        SUM(COALESCE(om.AvailableNForNMax, om.AvailableN))
    FROM OrganicManures om
    WHERE om.ManagementPeriodID = @ManagementPeriodID
	AND om.ManureTypeID NOT IN (33,34,40);

    SELECT @TotalFertiliserN =
        ISNULL(SUM(fm.N),0)
    FROM FertiliserManures fm
    WHERE fm.ManagementPeriodID = @ManagementPeriodID;

    SET @CombinedTotalN = @TotalOrganicN + @TotalFertiliserN;


    --------------------------------------------------------------------
    -- 16) Exceed check
    --------------------------------------------------------------------
    IF @CombinedTotalN > @NMaxRate
        SET @IsNExceeding = 1;


    --------------------------------------------------------------------
    -- 17) Final Output (UPDATED)
    --------------------------------------------------------------------
    SELECT
        @ManureID                   AS ManureID,
        @ManagementPeriodID         AS ManagementPeriodID,
        @CropID                     AS CropID,
        @FieldID                    AS FieldID,
        @FarmID                     AS FarmID,
        @CountryID                  AS CountryID,

        @IsFieldEngland             AS IsFieldEngland,
        @IsFieldWales               AS IsFieldWales,
        @IsFieldWithinNVZ           AS IsFieldWithinNVZ,

        @CropTypeID                 AS CropTypeID,
        @CropYear                   AS CropYear,
        @CropYield                  AS CropYield,

        @TotalOrganicN              AS TotalOrganicN,
        @TotalFertiliserN           AS TotalFertiliserN,
        @CombinedTotalN             AS CombinedTotalN,

        @NMaxRate                   AS ComputedNMaxRate,
		@BaseNMaxRate               AS BaseNMaxRate,
        @IsCropTypeHasNMax          AS IsCropTypeHasNMax,
        @HasPrevCurrSpecialManure   AS HasPrevOrCurrSpecialManure,
        @IsNExceeding               AS IsNExceeding;
END;