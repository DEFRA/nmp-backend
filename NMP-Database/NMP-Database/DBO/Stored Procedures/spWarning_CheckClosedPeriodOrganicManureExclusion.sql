



CREATE  PROCEDURE [dbo].[spWarning_CheckClosedPeriodOrganicManureExclusion]
    @OrganicManureID INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES
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
        @IsFarmRegisteredOrganic BIT = 0,   -- ⭐ NEW RETURN VARIABLE

        @IsHighRanManures BIT = 0,
        @IsRestrictedCropTypeNotExist BIT = 0,

        @AppMMDD INT,
        @SowMMDD INT,

        @AppYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,

        @ClosedStartDate DATE,
        @ClosedEndDate DATE,

        @IsWithinClosedPeriod BIT = 0;


    --------------------------------------------------------------------
    -- 1) Load OrganicManure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = om.ManagementPeriodID,
        @ApplicationDate    = om.ApplicationDate,
        @ManureTypeID       = om.ManureTypeID,
        @N                  = om.N
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureID;


    --------------------------------------------------------------------
    -- 2) Resolve ManagementPeriod → Crop
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
    -- 4) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID  = f.SoilTypeID,
        @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmID      = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;


    --------------------------------------------------------------------
    -- 5) Load Farm (Country + Organic)
    --------------------------------------------------------------------
    SELECT
        @CountryID = fm.CountryID,
        @RegisteredOrganicProducer =
            CASE WHEN ISNULL(fm.RegisteredOrganicProducer,0)=1 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    -- Set new return variable
    SET @IsFarmRegisteredOrganic = @RegisteredOrganicProducer;   -- ⭐ NEW


    --------------------------------------------------------------------
    -- 6) Country Flags
    --------------------------------------------------------------------
    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWelsh   = 1;


    --------------------------------------------------------------------
    -- 7) High-RAN Manures
    --------------------------------------------------------------------
    IF @ManureTypeID IN (8,12,13,14,15,18,45,46,49,51)
         SET @IsHighRanManures = 1;
    ELSE SET @IsHighRanManures = 0;


    --------------------------------------------------------------------
    -- 8) MMDD Values
    --------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @SowMMDD = CASE WHEN @SowingDate IS NULL
                        THEN NULL
                        ELSE MONTH(@SowingDate)*100 + DAY(@SowingDate)
                   END;


    --------------------------------------------------------------------
    -- 9) Perennial Flag
    --------------------------------------------------------------------
    SELECT TOP(1)
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;


    --------------------------------------------------------------------
    -- 10) Has Prior Year Plantings?
    --------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM Crops cprev
               WHERE cprev.FieldID=@FieldID AND cprev.Year < @CropYear)
         SET @HasPriorYearPlantings = 1;
    ELSE SET @HasPriorYearPlantings = 0;


    --------------------------------------------------------------------
    -- 11) YEAR CYCLE LOGIC (Aug 1 → July 31)
    --------------------------------------------------------------------
    SET @AppYear = YEAR(@ApplicationDate);

    IF @AppMMDD < 801
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@AppYear-1,8,1);
        SET @YearCycleEnd   = DATEFROMPARTS(@AppYear,7,31);
    END
    ELSE
    BEGIN
        SET @YearCycleStart = DATEFROMPARTS(@AppYear,8,1);
        SET @YearCycleEnd   = DATEFROMPARTS(@AppYear+1,7,31);
    END;


    --------------------------------------------------------------------
    -- 12) CLOSED PERIOD LOGIC
    --------------------------------------------------------------------
    SET @ClosedStartDate = NULL;
    SET @ClosedEndDate = NULL;

    -- Grass (CropType 140)
    IF @CropTypeID = 140
    BEGIN
        IF @SoilTypeID IN (0,1)
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
            SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
        END
        ELSE
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,15);
            SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
        END
    END
    ELSE
    BEGIN
        -- Non-grass logic...
        IF @IsPerennial = 0
        BEGIN
            IF @SoilTypeID IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                BEGIN
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                    SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                END
                ELSE
                BEGIN
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
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
            IF @SoilTypeID IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                BEGIN
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                    SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                END
                ELSE
                BEGIN
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
                    SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                END

                IF @HasPriorYearPlantings = 1
                BEGIN
                    SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
                    SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
                END
            END
            ELSE
            BEGIN
                SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
    END;


    --------------------------------------------------------------------
    -- 13) Closed Period Membership
    --------------------------------------------------------------------
    SET @IsWithinClosedPeriod =
        CASE WHEN @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
             THEN 1 ELSE 0 END;


    --------------------------------------------------------------------
    -- 14) RESTRICTED CROP TYPE CHECK
    --------------------------------------------------------------------
    IF @CropTypeID NOT IN (
        20,60,73,74,43,41,189,44,194,195,
        61,62,63,64,70,78,92,93,140
    )
         SET @IsRestrictedCropTypeNotExist = 1;
    ELSE SET @IsRestrictedCropTypeNotExist = 0;


    --------------------------------------------------------------------
    -- 15) FINAL OUTPUT  (UPDATED)
    --------------------------------------------------------------------
    SELECT
        @OrganicManureID              AS OrganicManureID,
        @CropID                       AS CropID,
        @CropTypeID                   AS CropTypeID,
        @IsRestrictedCropTypeNotExist AS IsRestrictedCropTypeNotExist,

        @IsFieldInEngland             AS IsFieldInEngland,
        @IsFieldInWelsh               AS IsFieldInWelsh,
        @IsWithinNVZ                  AS IsWithinNVZ,

        @IsFarmRegisteredOrganic      AS IsFarmRegisteredOrganic,   -- ⭐ NEW

        @IsHighRanManures             AS IsHighRanManures,
        @ApplicationDate              AS ApplicationDate,
        @ClosedStartDate              AS ClosedPeriodStart,
        @ClosedEndDate                AS ClosedPeriodEnd,
        @IsWithinClosedPeriod         AS InsideClosedPeriod,

        @N                            AS OrganicManureN;
END;