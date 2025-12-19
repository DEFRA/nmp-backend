


CREATE   PROCEDURE [dbo].[spWarning_CheckClosedPeriodOrganicManure]
    @OrganicManureID INT
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
        @CropYear INT,
        @SowingDate DATETIME,
        @ApplicationDate DATETIME,
        @ManureTypeID INT,
        @SoilTypeID INT,
        @N DECIMAL(18,3),

        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        @IsFieldInEngland BIT = 0,
        @IsFieldInWelsh BIT = 0,
        @IsWithinNVZ BIT = 0,
        @RegisteredOrganicProducer BIT = 0,

        -- exact flag name you requested
        @IsHighRanManures BIT = 0,

        @AppMMDD INT,
        @SowMMDD INT,

        -- Year-cycle & closed period dates
        @YearCycleStart DATE,
        @YearCycleEnd   DATE,
        @AppYear INT,
        @ClosedStartDate DATE,
        @ClosedEndDate DATE,

        -- final flags
        @IsWithinClosedPeriod BIT = 0;

    --------------------------------------------------------------------
    -- 1) Load OrganicManure basic info
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = om.ManagementPeriodID,
        @ApplicationDate    = om.ApplicationDate,
        @ManureTypeID       = om.ManureTypeID,
        @N                  = om.N
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureID;

    --------------------------------------------------------------------
    -- 2) ManagementPeriod -> Crop
    --------------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;

    --------------------------------------------------------------------
    -- 3) Load Crop
    --------------------------------------------------------------------
    SELECT
        @FieldID    = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @CropYear   = c.Year,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 4) Load Field (Soil, NVZ, Farm)
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID  = f.SoilTypeID,
        @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0) = 1 THEN 1 ELSE 0 END,
        @FarmID      = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 5) Load Farm (Country, RegisteredOrganicProducer)
    --------------------------------------------------------------------
    SELECT
        @CountryID = fm.CountryID,
        @RegisteredOrganicProducer = CASE WHEN ISNULL(fm.RegisteredOrganicProducer,0) = 1 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    --------------------------------------------------------------------
    -- 6) Country flags (England/Wales)
    --------------------------------------------------------------------
    IF @CountryID = 1
    BEGIN
        SET @IsFieldInEngland = 1;
    END
    ELSE
    BEGIN
        SET @IsFieldInEngland = 0;
    END

    IF @CountryID = 3
    BEGIN
        SET @IsFieldInWelsh = 1;
    END
    ELSE
    BEGIN
        SET @IsFieldInWelsh = 0;
    END

    --------------------------------------------------------------------
    -- 7) IsHighRanManures (manure-type check)
    --    exact flag name as requested
    --------------------------------------------------------------------
    IF @ManureTypeID IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;
    ELSE
        SET @IsHighRanManures = 0;

    --------------------------------------------------------------------
    -- 8) Convert dates to MMDD ints (for sowing comparison)
    --------------------------------------------------------------------
    IF @ApplicationDate IS NOT NULL
        SET @AppMMDD = MONTH(@ApplicationDate) * 100 + DAY(@ApplicationDate);
    ELSE
        SET @AppMMDD = NULL;

    IF @SowingDate IS NOT NULL
        SET @SowMMDD = MONTH(@SowingDate) * 100 + DAY(@SowingDate);
    ELSE
        SET @SowMMDD = NULL;

    --------------------------------------------------------------------
    -- 9) Get IsPerennial from CropTypeLinking (if exists)
    --------------------------------------------------------------------
    SELECT TOP (1)
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    IF @IsPerennial IS NULL
        SET @IsPerennial = 0;

    --------------------------------------------------------------------
    -- 10) Prior-year planting check (for perennials)
    --------------------------------------------------------------------
    IF @CropYear IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1 FROM Crops cprev
            WHERE cprev.FieldID = @FieldID
              AND cprev.Year < @CropYear
        )
        BEGIN
            SET @HasPriorYearPlantings = 1;
        END
        ELSE
        BEGIN
            SET @HasPriorYearPlantings = 0;
        END
    END
    ELSE
    BEGIN
        SET @HasPriorYearPlantings = 0;
    END

    --------------------------------------------------------------------
    -- 11) YEAR-CYCLE: AUG 1 -> JUL 31 (based on ApplicationDate)
    --------------------------------------------------------------------
    IF @ApplicationDate IS NULL
    BEGIN
        -- if no application date, we can't compute cycle; treat as not within closed period
        SET @YearCycleStart = NULL;
        SET @YearCycleEnd   = NULL;
    END
    ELSE
    BEGIN
        SET @AppYear = YEAR(@ApplicationDate);

        IF (MONTH(@ApplicationDate) * 100 + DAY(@ApplicationDate)) < 801
        BEGIN
            SET @YearCycleStart = DATEFROMPARTS(@AppYear - 1, 8, 1);
            SET @YearCycleEnd   = DATEFROMPARTS(@AppYear,     7, 31);
        END
        ELSE
        BEGIN
            SET @YearCycleStart = DATEFROMPARTS(@AppYear,     8, 1);
            SET @YearCycleEnd   = DATEFROMPARTS(@AppYear + 1, 7, 31);
        END
    END

    --------------------------------------------------------------------
    -- 12) CLOSED PERIOD: compute ClosedStartDate and ClosedEndDate
    --     Rules mapped into the YearCycle (AUG->JUL)
    --------------------------------------------------------------------
    SET @ClosedStartDate = NULL;
    SET @ClosedEndDate   = NULL;

    IF @ApplicationDate IS NOT NULL
    BEGIN
        IF @CropTypeID = 140
        BEGIN
            IF @SoilTypeID IN (0,1)
            BEGIN
                -- 1 Sep -> 31 Dec (same cycle year)
                SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart), 9, 1);
                SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
            END
            ELSE
            BEGIN
                -- 15 Oct -> 31 Jan (crosses to next calendar year)
                SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,15);
                SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
        ELSE
        BEGIN
            -- Non-140 crop types (perennial vs non-perennial logic)
            IF @IsPerennial = 0
            BEGIN
                IF @SoilTypeID IN (0,1)
                BEGIN
                    IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    BEGIN
                        SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart), 8, 1);
                        SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                    END
                    ELSE
                    BEGIN
                        SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart), 9,16);
                        SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                    END
                END
                ELSE
                BEGIN
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                    SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
                END
            END
            ELSE
            BEGIN
                -- IsPerennial = 1
                IF @SoilTypeID IN (0,1)
                BEGIN
                    IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    BEGIN
                        SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart), 8, 1);
                        SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                    END
                    ELSE
                    BEGIN
                        SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart), 9,16);
                        SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                    END

                    IF @HasPriorYearPlantings = 1
                    BEGIN
                        -- stricter window
                        SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart), 9,16);
                        SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                    END
                END
                ELSE
                BEGIN
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                    SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
                END
            END
        END
    END

    --------------------------------------------------------------------
    -- 13) Final closed-period membership test (ApplicationDate between ClosedStartDate..ClosedEndDate)
    --------------------------------------------------------------------
    SET @IsWithinClosedPeriod = 0;

    IF @ApplicationDate IS NOT NULL AND @ClosedStartDate IS NOT NULL AND @ClosedEndDate IS NOT NULL
    BEGIN
        IF @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
            SET @IsWithinClosedPeriod = 1;
        ELSE
            SET @IsWithinClosedPeriod = 0;
    END
    ELSE
    BEGIN
        SET @IsWithinClosedPeriod = 0;
    END

    --------------------------------------------------------------------
    -- 14) Final SELECT: return flags + debug values
    --------------------------------------------------------------------
    SELECT
        @OrganicManureID         AS OrganicManureID,
        @ManagementPeriodID      AS ManagementPeriodID,
        @CropID                  AS CropID,
        @FieldID                 AS FieldID,
        @FarmID                  AS FarmID,
        @CountryID               AS CountryID,
        @IsFieldInEngland        AS IsFieldInEngland,
        @IsFieldInWelsh          AS IsFieldInWelsh,
        @IsWithinNVZ             AS IsWithinNVZ,
        @RegisteredOrganicProducer AS RegisteredOrganicProducer,
        @ManureTypeID            AS ManureTypeID,
        @IsHighRanManures        AS IsHighRanManures,
        @CropTypeID              AS CropTypeID,
        @SoilTypeID              AS SoilTypeID,
        @SowingDate              AS SowingDate,
        @ApplicationDate         AS ApplicationDate,
        @YearCycleStart          AS YearCycleStart,
        @YearCycleEnd            AS YearCycleEnd,
        @ClosedStartDate         AS ClosedPeriodStart,
        @ClosedEndDate           AS ClosedPeriodEnd,
        @IsWithinClosedPeriod    AS IsWithinClosedPeriod,
        @N                       AS OrganicManureN;

END;