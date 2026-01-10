
CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodEndFebruaryPoultryManure]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------
    -- VARIABLES
    --------------------------------------------------------
    DECLARE
        @ManagementPeriodId INT,
        @CropId INT,
        @FieldId INT,
        @FarmId INT,
        @CountryId INT,
        @CropTypeId INT,
        @CropYear INT,
        @SowingDate DATE,
        @ApplicationDate DATE,
        @ManureTypeId INT,
        @ApplicationRate DECIMAL(18,3),
        @SoilTypeId INT,

        -- FLAGS
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNvz BIT = 0,
        @IsAllowedPoultryManure BIT = 0,
        @IsApplicationRateAboveEight BIT = 0,
        @IsInsideClosedPeriodToFebruary BIT = 0,

        -- PERENNIAL
        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        -- DATE HELPERS
        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @FebruaryEnd DATE,
        @FebruaryYear INT;

    --------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = CAST(om.ApplicationDate AS DATE),
        @ManureTypeId = om.ManureTypeID,
        @ApplicationRate = ISNULL(om.ApplicationRate,0)
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;

    --------------------------------------------------------
    -- 2) Load CropId from ManagementPeriod
    --------------------------------------------------------
    SELECT @CropId = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodId;

    --------------------------------------------------------
    -- 3) Load Crop
    --------------------------------------------------------
    SELECT
        @FieldId = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @CropYear = c.Year,
        @SowingDate = CAST(c.SowingDate AS DATE)
    FROM Crops c
    WHERE c.ID = @CropId;

    --------------------------------------------------------
    -- 4) Perennial flag
    --------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = ISNULL(ctl.IsPerennial,0)
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeId;

    --------------------------------------------------------
    -- 5) Prior year perennial exists?
    --------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops c2
        INNER JOIN CropTypeLinkings ctl2 ON ctl2.CropTypeID = c2.CropTypeID
        WHERE c2.FieldID = @FieldId
          AND c2.Year < @CropYear
          AND ctl2.IsPerennial = 1
    )
        SET @HasPriorYearPlantings = 1;

    --------------------------------------------------------
    -- 6) Load Field & NVZ
    --------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = ISNULL(f.IsWithinNVZ,0),
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;

    --------------------------------------------------------
    -- 7) Load Farm / Country
    --------------------------------------------------------
    SELECT @CountryId = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmId;

    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;

    --------------------------------------------------------
    -- 8) Allowed Poultry Manure (ONLY ID = 8)
    --------------------------------------------------------
    IF @ManureTypeId = 8 SET @IsAllowedPoultryManure = 1;

    --------------------------------------------------------
    -- 9) Rate > 8
    --------------------------------------------------------
    IF @ApplicationRate > 8 SET @IsApplicationRateAboveEight = 1;

    --------------------------------------------------------
    -- 10) Date helpers
    --------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @SowMMDD = CASE WHEN @SowingDate IS NULL THEN NULL
                        ELSE MONTH(@SowingDate)*100 + DAY(@SowingDate) END;
    SET @AppYear = YEAR(@ApplicationDate);

    --------------------------------------------------------
    -- 11) Year cycle (Aug → Jul)
    --------------------------------------------------------
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

    --------------------------------------------------------
    -- 12) CLOSED PERIOD LOGIC (FINAL)
    --------------------------------------------------------
    IF @CropTypeId = 140
    BEGIN
        -- GRASS
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
    ELSE
    BEGIN
        -- NON-GRASS
        IF @IsPerennial = 1 OR @HasPriorYearPlantings = 1
        BEGIN
            IF @SoilTypeId IN (0,1)
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
            END
            ELSE
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
        ELSE
        BEGIN
            IF @SoilTypeId IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                ELSE
                    SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);

                SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
            END
            ELSE
            BEGIN
                SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
    END;

    --------------------------------------------------------
    -- 13) February YEAR LOGIC (FIXED)
    --------------------------------------------------------
    IF MONTH(@ClosedPeriodEnd) = 12
        SET @FebruaryYear = YEAR(@ClosedPeriodEnd) + 1;
    ELSE
        SET @FebruaryYear = YEAR(@ClosedPeriodEnd);

    SET @FebruaryEnd =
        CASE WHEN DAY(EOMONTH(DATEFROMPARTS(@FebruaryYear,2,1))) = 29
             THEN DATEFROMPARTS(@FebruaryYear,2,29)
             ELSE DATEFROMPARTS(@FebruaryYear,2,28) END;

    --------------------------------------------------------
    -- 14) Inside closed period → February
    --------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodEnd AND @FebruaryEnd
        SET @IsInsideClosedPeriodToFebruary = 1;

    --------------------------------------------------------
    -- 15) FINAL OUTPUT
    --------------------------------------------------------
    SELECT
        @OrganicManureId AS OrganicManureId,
        @CropId AS CropId,
        @FieldId AS FieldId,
        @FarmId AS FarmId,
        @CountryId AS CountryId,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNvz AS IsWithinNvz,

        @SoilTypeId AS SoilTypeId,
        @IsAllowedPoultryManure AS IsAllowedPoultryManure,
        @IsApplicationRateAboveEight AS IsApplicationRateAboveEight,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,
        @FebruaryEnd AS FebruaryEnd,

        @IsInsideClosedPeriodToFebruary AS IsInsideClosedPeriodToFebruary;
END;