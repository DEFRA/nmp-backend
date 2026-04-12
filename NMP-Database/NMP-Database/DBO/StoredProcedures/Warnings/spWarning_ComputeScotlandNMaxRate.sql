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
        @ApplicationDate DATE,
        @IsOrganic BIT = 0,

        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,
        @SoilTypeID INT,
        @IsWithinNVZ BIT,
        @IsFieldWithinScotland BIT = 0,

        @NIndex INT,
        @BaseNMaxRate DECIMAL(18,3),
        @NMaxRate DECIMAL(18,3),

        @CropYield DECIMAL(18,3),
        @DefaultYield DECIMAL(18,3),
        @CropInfo1 INT,
        @WinterRainfall DECIMAL(18,3),
        @CropYear INT,

        @IsFallbackCrop BIT = 0,

        @TotalOrganicN DECIMAL(18,3),
        @TotalFertiliserN DECIMAL(18,3),
        @CombinedTotalN DECIMAL(18,3),
        @IsNExceeding BIT = 0;

    --------------------------------------------------------------------
    -- 1) Get ManagementPeriod + ApplicationDate
    --------------------------------------------------------------------
    SELECT 
        @ManagementPeriodID = ManagementPeriodID,
        @ApplicationDate = ApplicationDate,
        @IsOrganic = 1
    FROM OrganicManures WHERE ID = @ManureID;

    IF @ManagementPeriodID IS NULL
    BEGIN
        SELECT 
            @ManagementPeriodID = ManagementPeriodID,
            @ApplicationDate = ApplicationDate,
            @IsOrganic = 0
        FROM FertiliserManures WHERE ID = @ManureID;
    END

    IF @ManagementPeriodID IS NULL
    BEGIN
        RAISERROR('Invalid ManureID',16,1);
        RETURN;
    END

    --------------------------------------------------------------------
    -- 2) Crop
    --------------------------------------------------------------------
    SELECT @CropID = CropID
    FROM ManagementPeriods
    WHERE ID = @ManagementPeriodID;

    SELECT 
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @CropYield = ISNULL(c.Yield,0),
        @CropInfo1 = ISNULL(c.CropInfo1,0),
        @CropYear = c.Year
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 3) Field
    --------------------------------------------------------------------
    SELECT 
        @SoilTypeID = f.SoilTypeID,
        @FarmID = f.FarmID,
        @IsWithinNVZ = f.IsWithinNVZ
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 4) Scotland check
    --------------------------------------------------------------------
    SELECT @CountryID = CountryID FROM Farms WHERE ID = @FarmID;

    SET @IsFieldWithinScotland = CASE WHEN @CountryID = 2 THEN 1 ELSE 0 END;

    IF @IsFieldWithinScotland = 0
    BEGIN
        SELECT 0 AS NMaxRate, 'Not Scotland' AS Message;
        RETURN;
    END

    --------------------------------------------------------------------
    -- 5) NIndex
    --------------------------------------------------------------------
    SELECT TOP 1 @NIndex = r.NIndex
    FROM Recommendations r
    WHERE r.ManagementPeriodID = @ManagementPeriodID;

    --------------------------------------------------------------------
    -- 6) Base NMaxRate (UPDATED for CropTypeID 20 Jan–Jul)
    --------------------------------------------------------------------
    IF @CropTypeID = 20 
       AND @IsOrganic = 0 
       AND @ApplicationDate >= DATEFROMPARTS(YEAR(@ApplicationDate),1,1)
       AND @ApplicationDate <= DATEFROMPARTS(YEAR(@ApplicationDate),7,31)
    BEGIN
        SELECT TOP 1
            @BaseNMaxRate =
                CASE @NIndex
                    WHEN 1 THEN sn.ResidueGroup1
                    WHEN 2 THEN sn.ResidueGroup2
                    WHEN 3 THEN sn.ResidueGroup3
                    WHEN 4 THEN sn.ResidueGroup4
                    WHEN 5 THEN sn.ResidueGroup5
                    WHEN 6 THEN sn.ResidueGroup6
                END
        FROM ScotlandNMaxValues sn
        WHERE sn.CropTypeID = @CropTypeID
          AND sn.SoilTypeID = -1;
    END
    ELSE
    BEGIN
        SELECT TOP 1
            @BaseNMaxRate =
                CASE @NIndex
                    WHEN 1 THEN sn.ResidueGroup1
                    WHEN 2 THEN sn.ResidueGroup2
                    WHEN 3 THEN sn.ResidueGroup3
                    WHEN 4 THEN sn.ResidueGroup4
                    WHEN 5 THEN sn.ResidueGroup5
                    WHEN 6 THEN sn.ResidueGroup6
                END
        FROM ScotlandNMaxValues sn
        WHERE sn.CropTypeID = @CropTypeID
          AND sn.SoilTypeID = @SoilTypeID;
    END

    SET @NMaxRate = @BaseNMaxRate;

    --------------------------------------------------------------------
    -- 7) Default Yield
    --------------------------------------------------------------------
    SELECT @DefaultYield = DefaultYieldScotland
    FROM CropTypeLinkings
    WHERE CropTypeID = @CropTypeID;

    --------------------------------------------------------------------
    -- 8) Yield Adjustments (UNCHANGED except CropTypeID 20)
    --------------------------------------------------------------------
    IF @CropTypeID IN (0,53)
    BEGIN
        DECLARE @s1 INT = FLOOR((@CropYield - @DefaultYield) * 10);
        IF @s1 > 0 SET @NMaxRate += (@s1 * 2);
        IF @CropInfo1 = 2 SET @NMaxRate += 40;
    END
    ELSE IF @CropTypeID IN (1,52)
    BEGIN
        DECLARE @s2 INT = FLOOR((@CropYield - @DefaultYield) * 10);
        IF @s2 > 0 SET @NMaxRate += (@s2 * 1.5);
    END
    ELSE IF @CropTypeID IN (2,51,174)
    BEGIN
        DECLARE @s3 INT = FLOOR((@CropYield - @DefaultYield) * 10);
        IF @s3 > 0 SET @NMaxRate += (@s3 * 2);
        IF @CropInfo1 = 2 SET @NMaxRate += 40;
    END
    ELSE IF @CropTypeID IN (3,50,171)
    BEGIN
        DECLARE @s4 INT = FLOOR((@CropYield - @DefaultYield) * 10);
        IF @s4 > 0 SET @NMaxRate += (@s4 * 1.5);
        IF @CropInfo1 = 5 SET @NMaxRate += 15;
    END
    ELSE IF @CropTypeID IN (4,57,5,54,172)
    BEGIN
        DECLARE @s5 INT = FLOOR((@CropYield - @DefaultYield) * 10);
        IF @s5 > 0 SET @NMaxRate += (@s5 * 1.5);
    END

    --------------------------------------------------------------------
    -- ✅ CropTypeID = 20 (UPDATED)
    --------------------------------------------------------------------
    ELSE IF @CropTypeID = 20
    BEGIN
        IF @IsOrganic = 1 
           OR (
                @ApplicationDate >= DATEFROMPARTS(YEAR(@ApplicationDate),8,1)
            AND @ApplicationDate <= DATEFROMPARTS(YEAR(@ApplicationDate),12,31)
              )
        BEGIN
            IF @CropYield > @DefaultYield
                SET @NMaxRate += 30;
        END
    END

    --------------------------------------------------------------------
    -- 9) Fallback
    --------------------------------------------------------------------
    ELSE IF @CropTypeID NOT IN (
        0,53,1,52,2,51,174,3,50,171,4,57,5,54,172,
        20,160,161,162,163,7,55,199,9,56,173
    )
    BEGIN
        SET @IsFallbackCrop = 1;

        SELECT TOP 1 @NMaxRate = r.FertilizerN
        FROM Recommendations r
        WHERE r.ManagementPeriodID = @ManagementPeriodID;

        SET @BaseNMaxRate = @NMaxRate;
    END

    --------------------------------------------------------------------
    -- 10) Rainfall (UNCHANGED)
    --------------------------------------------------------------------
    IF @IsFallbackCrop = 0
    BEGIN
        SELECT TOP 1 
            @WinterRainfall = er.WinterRainfall
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