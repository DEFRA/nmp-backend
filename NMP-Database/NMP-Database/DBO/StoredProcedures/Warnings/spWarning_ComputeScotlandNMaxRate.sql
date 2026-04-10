
CREATE PROCEDURE [dbo].[spWarning_ComputeScotlandNMaxRate]
(
    @ManureID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- Variables
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,
        @SoilTypeID INT,
        @IsWithinNVZ BIT,
        @IsFieldWithinScotland BIT = 0,

        @NIndex INT,
        @BaseNMaxRate DECIMAL(18,3) = 0,
        @NMaxRate DECIMAL(18,3) = 0,

        @CropYield DECIMAL(18,3) = 0,
        @DefaultYield DECIMAL(18,3) = 0,
        @CropInfo1 INT = 0,
        @WinterRainfall DECIMAL(18,3) = 0,
        @YieldDiff DECIMAL(18,3) = 0,
        @YieldSteps INT = 0,

        @CropYear INT,
        @IsFallbackCrop BIT = 0,

        @TotalOrganicN DECIMAL(18,3) = 0,
        @TotalFertiliserN DECIMAL(18,3) = 0,
        @CombinedTotalN DECIMAL(18,3) = 0,
        @IsNExceeding BIT = 0;

    --------------------------------------------------------------------
    -- 1) ManagementPeriodID
    --------------------------------------------------------------------
    SELECT @ManagementPeriodID = ManagementPeriodID
    FROM OrganicManures WHERE ID = @ManureID;

    IF @ManagementPeriodID IS NULL
    BEGIN
        SELECT @ManagementPeriodID = ManagementPeriodID
        FROM FertiliserManures WHERE ID = @ManureID;
    END

    IF @ManagementPeriodID IS NULL
    BEGIN
        RAISERROR('Invalid ManureID',16,1);
        RETURN;
    END

    --------------------------------------------------------------------
    -- 2) CropID
    --------------------------------------------------------------------
    SELECT @CropID = CropID
    FROM ManagementPeriods
    WHERE ID = @ManagementPeriodID;

    --------------------------------------------------------------------
    -- 3) Crop
    --------------------------------------------------------------------
    SELECT 
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @CropYield = ISNULL(c.Yield,0),
        @CropInfo1 = ISNULL(c.CropInfo1,0),
        @CropYear = c.Year
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 4) Field
    --------------------------------------------------------------------
    SELECT 
        @SoilTypeID = f.SoilTypeID,
        @FarmID = f.FarmID,
        @IsWithinNVZ = f.IsWithinNVZ
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 5) Country → Scotland
    --------------------------------------------------------------------
    SELECT @CountryID = CountryID
    FROM Farms
    WHERE ID = @FarmID;

    SET @IsFieldWithinScotland = CASE WHEN @CountryID = 2 THEN 1 ELSE 0 END;

    IF @IsFieldWithinScotland = 0
    BEGIN
        SELECT 0 AS NMaxRate, 'Not Scotland' AS Message;
        RETURN;
    END

    --------------------------------------------------------------------
    -- 6) NIndex
    --------------------------------------------------------------------
  SELECT TOP 1 @NIndex = r.NIndex
  FROM Recommendations r
  WHERE r.ManagementPeriodID = @ManagementPeriodID;

    --------------------------------------------------------------------
    -- 7) Base NMaxRate (ResidueGroup)
    --------------------------------------------------------------------
    SELECT TOP 1
        @BaseNMaxRate =
            CASE @NIndex
                WHEN 1 THEN sn.ResidueGroup1
                WHEN 2 THEN sn.ResidueGroup2
                WHEN 3 THEN sn.ResidueGroup3
                WHEN 4 THEN sn.ResidueGroup4
                WHEN 5 THEN sn.ResidueGroup5
                WHEN 6 THEN sn.ResidueGroup6
                ELSE 0
            END
    FROM ScotlandNMaxValues sn
    WHERE sn.CropTypeID = @CropTypeID
      AND sn.SoilTypeID = @SoilTypeID;

    -- Initialize working NMaxRate
    SET @NMaxRate = @BaseNMaxRate;

    --------------------------------------------------------------------
    -- 8) Default Yield
    --------------------------------------------------------------------
    SELECT 
        @DefaultYield = ISNULL(DefaultYieldScotland,0)
    FROM CropTypeLinkings
    WHERE CropTypeID = @CropTypeID;

    SET @YieldDiff = @CropYield - @DefaultYield;

    IF @YieldDiff > 0
        SET @YieldSteps = FLOOR(@YieldDiff * 10);

    --------------------------------------------------------------------
    -- 9) Yield Adjustments
    --------------------------------------------------------------------
    IF @CropTypeID IN (0,53)
    BEGIN
        SET @NMaxRate += (@YieldSteps * 2);
        IF @CropInfo1 = 2 SET @NMaxRate += 40;
    END
    ELSE IF @CropTypeID IN (1,52)
        SET @NMaxRate += (@YieldSteps * 1.5);

    ELSE IF @CropTypeID IN (2,51,174)
    BEGIN
        SET @NMaxRate += (@YieldSteps * 2);
        IF @CropInfo1 = 2 SET @NMaxRate += 40;
    END

    ELSE IF @CropTypeID IN (3,50,171)
    BEGIN
        SET @NMaxRate += (@YieldSteps * 1.5);
        IF @CropInfo1 = 5 SET @NMaxRate += 15;
    END

    ELSE IF @CropTypeID IN (4,57,5,54,172)
        SET @NMaxRate += (@YieldSteps * 1.5);

    ELSE IF @CropTypeID = 21
    BEGIN
        IF @CropYield > @DefaultYield
            SET @NMaxRate += 30;
    END

    ELSE IF @CropTypeID NOT IN (
        0,53,1,52,2,51,174,3,50,171,4,57,5,54,172,
        20,21,160,161,162,163,7,55,199,9,56,173
    )
    BEGIN
        SET @IsFallbackCrop = 1;

        SELECT TOP 1 @NMaxRate = ISNULL(r.FertilizerN,0)
        FROM Recommendations r
        WHERE r.ManagementPeriodID = @ManagementPeriodID;

        SET @BaseNMaxRate = @NMaxRate; 
    END

    --------------------------------------------------------------------
    -- 10) Rainfall (skip for fallback)
    --------------------------------------------------------------------
    IF @IsFallbackCrop = 0
    BEGIN
        SELECT TOP 1 
            @WinterRainfall = ISNULL(er.WinterRainfall,0)
        FROM ExcessRainfalls er
        WHERE er.FarmID = @FarmID
          AND er.Year = @CropYear;

        IF @WinterRainfall >= 450 AND @SoilTypeID IN (10,11,12)
        BEGIN
            IF @NIndex = 2 SET @NMaxRate += 10;
            ELSE IF @NIndex IN (3,4,5,6) SET @NMaxRate += 20;
        END

        IF @WinterRainfall >= 450 AND @SoilTypeID IN (13,14,15)
        BEGIN
            IF @NIndex IN (2,3,4,5,6) SET @NMaxRate += 10;
        END
    END

    --------------------------------------------------------------------
    -- 11) Total N
    --------------------------------------------------------------------
    SELECT
        @TotalOrganicN =
            ISNULL(SUM(COALESCE(om.AvailableNForNMax, om.AvailableN)),0)
    FROM OrganicManures om
    JOIN ManagementPeriods mp ON om.ManagementPeriodID = mp.ID
    WHERE mp.CropID = @CropID;

    SELECT
        @TotalFertiliserN =
            ISNULL(SUM(fm.N),0)
    FROM FertiliserManures fm
    JOIN ManagementPeriods mp ON fm.ManagementPeriodID = mp.ID
    WHERE mp.CropID = @CropID;

    SET @CombinedTotalN = @TotalOrganicN + @TotalFertiliserN;

    --------------------------------------------------------------------
    -- 12) Exceed Check
    --------------------------------------------------------------------
    IF @CombinedTotalN > @NMaxRate
        SET @IsNExceeding = 1;

    --------------------------------------------------------------------
    -- 13) Final Output
    --------------------------------------------------------------------
    SELECT
        @ManureID AS ManureID,
        @CropID AS CropID,
        @CropTypeID AS CropTypeID,
		@IsFieldWithinScotland AS IsFieldWithinScotland,
        @IsWithinNVZ AS IsWithinNVZ,
        @NIndex AS NIndex,
        @BaseNMaxRate AS BaseNMaxRate,
        @NMaxRate AS ComputedNMaxRate,
        @CombinedTotalN AS CombinedTotalN,
        @IsNExceeding AS IsNExceeding,
        @IsFallbackCrop AS IsFallbackCrop;

END;