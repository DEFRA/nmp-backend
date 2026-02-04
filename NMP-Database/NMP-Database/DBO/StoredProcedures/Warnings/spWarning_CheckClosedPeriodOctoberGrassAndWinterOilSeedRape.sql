

CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodOctoberGrassAndWinterOilSeedRape]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES (alphabet-only)
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodId INT,
        @CropId INT,
        @FieldId INT,
        @FarmId INT,
        @CountryId INT,
        @CropTypeId INT,
        @CropYear INT,
        @SowingDate DATETIME,
        @ApplicationDate DATETIME,
        @SoilTypeId INT,
        @ManureTypeId INT,
        @Nitrogen DECIMAL(18,3),
        @ApplicationRate DECIMAL(18,3),

        -- Flags
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNvz BIT = 0,
        @IsHighRanManures BIT = 0,
        @IsGrassCropType BIT = 0,
        @IsWinterOilSeedRapeCropType BIT = 0,
        @IsInsideClosedPeriodToOctober BIT = 0,

        -- Date helpers
        @ApplicationMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @OctoberEnd DATE,

        -- Perennial helpers (from CropTypeLinkings)
        @IsPerennial BIT = 0,
        @HasPriorYearPerennialPlantings BIT = 0,
        @SowingMonthDay INT;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate    = om.ApplicationDate,
        @ManureTypeId       = om.ManureTypeID,
        @Nitrogen           = om.N,
        @ApplicationRate    = om.ApplicationRate
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;


    --------------------------------------------------------------------
    -- 2) Load Crop ID from ManagementPeriod
    --------------------------------------------------------------------
    SELECT @CropId = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodId;


    --------------------------------------------------------------------
    -- 3) Load Crop
    --------------------------------------------------------------------
    SELECT
        @FieldId    = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @CropYear   = c.Year,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropId;


    --------------------------------------------------------------------
    -- 4) CropType Flags (140 Grass, 20 WOSR)
    --------------------------------------------------------------------
    IF @CropTypeId = 140 SET @IsGrassCropType = 1;
    IF @CropTypeId = 20  SET @IsWinterOilSeedRapeCropType = 1;


    --------------------------------------------------------------------
    -- 5) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------------------
    -- 6) Load Farm (no RegisteredOrganicProducer here)
    --------------------------------------------------------------------
    SELECT @CountryId = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmId;


    --------------------------------------------------------------------
    -- 7) England / Wales Flags
    --------------------------------------------------------------------
    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------------------
    -- 8) High RAN Manure Types
    --------------------------------------------------------------------
    IF @ManureTypeId IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;
    ELSE
        SET @IsHighRanManures = 0;


    --------------------------------------------------------------------
    -- 9) Date Helpers
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @ApplicationYear = YEAR(@ApplicationDate);

    IF @SowingDate IS NOT NULL
        SET @SowingMonthDay = MONTH(@SowingDate)*100 + DAY(@SowingDate);
    ELSE
        SET @SowingMonthDay = NULL;


    --------------------------------------------------------------------
    -- 10) Year Cycle: Aug 1 → Jul 31
    --------------------------------------------------------------------
    IF @ApplicationMonthDay < 801
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@ApplicationYear-1,8,1);
        SET @YearCycleEnd   = DATEFROMPARTS(@ApplicationYear,7,31);
    END
    ELSE
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@ApplicationYear,8,1);
        SET @YearCycleEnd   = DATEFROMPARTS(@ApplicationYear+1,7,31);
    END;


    --------------------------------------------------------------------
    -- 11) PERENNIAL FLAG from CropTypeLinkings + prior-year perennial check
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = CASE WHEN ISNULL(ct.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ct
    WHERE ct.CropTypeID = @CropTypeId;

    IF @IsPerennial IS NULL SET @IsPerennial = 0;

    -- Prior-year perennial plantings on this field (any previous year)
    IF EXISTS (
        SELECT 1
        FROM Crops cprev
        INNER JOIN CropTypeLinkings ctlPrev ON ctlPrev.CropTypeID = cprev.CropTypeID
        WHERE cprev.FieldID = @FieldId
          AND cprev.Year < ISNULL(@CropYear, YEAR(@ApplicationDate))
          AND ISNULL(ctlPrev.IsPerennial,0) = 1
    )
        SET @HasPriorYearPerennialPlantings = 1;
    ELSE
        SET @HasPriorYearPerennialPlantings = 0;


    --------------------------------------------------------------------
    -- 12) Determine Closed Period (Option A)
    --     - Grass (140): same as before
    --     - Non-grass (WOSR / others): incorporate IsPerennial and prior-year perennial
    --------------------------------------------------------------------
    SET @ClosedPeriodStart = NULL;
    SET @ClosedPeriodEnd   = NULL;

    IF @CropTypeId = 140  -- GRASS
    BEGIN
        IF @SoilTypeId IN (0,1)
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
        ELSE
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,15);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
        END
    END
    ELSE -- NON-GRASS (e.g., WOSR = 20 or others)
    BEGIN
        -- If any prior-year perennial plantings exist on this field, apply the "prior-year perennial" rule:
        IF @HasPriorYearPerennialPlantings = 1
        BEGIN
            -- Prior-year perennial shortens to 16 Sep – 31 Dec (Option A behaviour)
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
        ELSE
        BEGIN
            -- No prior-year perennials: use current-crop perennial flag and sowing date
            IF @IsPerennial = 0 -- NON-PERENNIAL
            BEGIN
                IF @SoilTypeId IN (0,1)
                BEGIN
                    -- Non-perennial on sandy/shallow soils -> start 16 Sep to 31 Dec (Option A)
                    -- If Sowing date is known and before 16 Sep we still use 16 Sep start (Option A)
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                END
                ELSE
                BEGIN
                    -- Non-perennial on other soils -> 1 Oct – 31 Jan (cross-year)
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
                END
            END
            ELSE -- CURRENT CROP IS PERENNIAL
            BEGIN
                IF @SoilTypeId IN (0,1)
                BEGIN
                    -- Perennial on sandy/shallow soils: shorten to 1 Aug / 16 Sep or 16 Sep depending on sowing
                    IF @SowingMonthDay IS NULL OR @SowingMonthDay >= 916
                    BEGIN
                        -- If sowing on/after 16 Sep or unknown -> start 8/1 (kept for compatibility),
                        -- but Option A prefers 16 Sep when prior-year exists; since prior-year was false we keep 8/1 -> 12/31
                        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                    END
                    ELSE
                    BEGIN
                        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
                        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                    END

                    -- If later we detect prior-year perennial we would have set 9/16 - 12/31 already above
                END
                ELSE
                BEGIN
                    -- Perennial on other soils: default to 1 Oct – 31 Jan (cross-year)
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                    SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);

                    -- But if prior-year perennial existed we would have used 9/16 - 12/31 above
                END
            END
        END
    END;


    --------------------------------------------------------------------
    -- 13) October 31 Boundary
    --------------------------------------------------------------------
    SET @OctoberEnd = DATEFROMPARTS(YEAR(@ClosedPeriodStart),10,31);


    --------------------------------------------------------------------
    -- 14) Application inside Closed Period → October 31?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @OctoberEnd
        SET @IsInsideClosedPeriodToOctober = 1;
    ELSE
        SET @IsInsideClosedPeriodToOctober = 0;


    --------------------------------------------------------------------
    -- 15) Final Output (All flags separately)
    --------------------------------------------------------------------
    SELECT
        @OrganicManureId AS OrganicManureId,
        @CropId AS CropId,
        @CropTypeId AS CropTypeId,
        @IsGrassCropType AS IsGrassCropType,
        @IsWinterOilSeedRapeCropType AS IsWinterOilSeedRapeCropType,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNvz AS IsWithinNvz,
        @IsHighRanManures AS IsHighRanManures,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,
        @OctoberEnd AS OctoberEnd,
        @IsInsideClosedPeriodToOctober AS IsInsideClosedPeriodToOctober,

        @IsPerennial AS IsPerennial,
        @HasPriorYearPerennialPlantings AS HasPriorYearPerennialPlantings,

        @Nitrogen AS CurrentNitrogen,
        @ApplicationRate AS ApplicationRate;
END;