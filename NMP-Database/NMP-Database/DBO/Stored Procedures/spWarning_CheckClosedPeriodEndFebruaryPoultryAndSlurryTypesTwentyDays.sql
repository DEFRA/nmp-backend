
CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodEndFebruaryPoultryAndSlurryTypesTwentyDays]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- VARIABLES
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodId INT,
        @CropId INT,
        @FieldId INT,
        @FarmId INT,
        @CountryId INT,
        @CropTypeId INT,
        @SowingDate DATETIME,
        @ApplicationDate DATETIME,
        @ManureTypeId INT,
        @SoilTypeId INT,

        -- FLAGS
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNvz BIT = 0,
        @IsAllowedManureType BIT = 0,
        @IsInsideClosedPeriodToFebruary BIT = 0,
        @IsPreviousApplicationWithinTwentyDays BIT = 0,

        -- DATE HELPERS
        @ApplicationMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @FebruaryEnd DATE,

        -- Perennial Rules
        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = om.ApplicationDate,
        @ManureTypeId = om.ManureTypeID
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;


    --------------------------------------------------------------------
    -- 2) Load Crop from ManagementPeriod
    --------------------------------------------------------------------
    SELECT @CropId = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodId;


    --------------------------------------------------------------------
    -- 3) Load Crop
    --------------------------------------------------------------------
    SELECT
        @FieldId = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropId;


    --------------------------------------------------------------------
    -- 4) Get IsPerennial from CropTypeLinkings
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = CASE WHEN ISNULL(IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings
    WHERE CropTypeID = @CropTypeId;


    --------------------------------------------------------------------
    -- 5) Prior-year perennial check
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops pc
        INNER JOIN CropTypeLinkings pcl ON pcl.CropTypeID = pc.CropTypeID
        WHERE pc.FieldID = @FieldId
          AND pc.Year < YEAR(@ApplicationDate)
          AND ISNULL(pcl.IsPerennial,0) = 1
    )
        SET @HasPriorYearPlantings = 1;


    --------------------------------------------------------------------
    -- 6) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------------------
    -- 7) Load Farm Country
    --------------------------------------------------------------------
    SELECT @CountryId = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmId;

    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------------------
    -- 8) Allowed manure types
    --------------------------------------------------------------------
    IF @ManureTypeId IN (8,12,45,13,14,15,18)
        SET @IsAllowedManureType = 1;


    --------------------------------------------------------------------
    -- 9) Previous application within 20 days
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM OrganicManures omPrev
        WHERE omPrev.ManagementPeriodID = @ManagementPeriodId
          AND omPrev.ID <> @OrganicManureId
          AND omPrev.ManureTypeID IN (8,12,45,13,14,15,18)
          AND DATEDIFF(DAY, omPrev.ApplicationDate, @ApplicationDate)
                 BETWEEN 0 AND 20
    )
        SET @IsPreviousApplicationWithinTwentyDays = 1;


    --------------------------------------------------------------------
    -- 10) Date helpers
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @ApplicationYear = YEAR(@ApplicationDate);


    --------------------------------------------------------------------
    -- 11) Year cycle (1 Aug → 31 July)
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


    ------------------------------------------------------------------------
    -- 12) CLOSED PERIOD LOGIC (Full Organic Manure Rule)
    ------------------------------------------------------------------------

    -- Priority 1: Previous-year perennial → SANDY & NON-SANDY SAME
    IF @HasPriorYearPlantings = 1
    BEGIN
        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);
        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
    END
    ELSE
    BEGIN
        -- Priority 2: Grass (CropType 140)
        IF @CropTypeId = 140
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
        ELSE
        BEGIN
            -- Non-perennial
            IF @IsPerennial = 0
            BEGIN
                IF @SoilTypeId IN (0,1)
                BEGIN
                    IF @SowingDate IS NULL
                        OR (MONTH(@SowingDate)*100 + DAY(@SowingDate)) >= 916
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
            ELSE
            BEGIN
                -- Perennial this year
                IF @SoilTypeId IN (0,1)
                BEGIN
                    IF @SowingDate IS NULL
                        OR (MONTH(@SowingDate)*100 + DAY(@SowingDate)) >= 916
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
        END
    END


    --------------------------------------------------------------------
    -- 13) February end
    --------------------------------------------------------------------
    IF (YEAR(@ApplicationDate) % 4 = 0 AND YEAR(@ApplicationDate) % 100 <> 0)
        OR (YEAR(@ApplicationDate) % 400 = 0)
        SET @FebruaryEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,29);
    ELSE
        SET @FebruaryEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,28);


    --------------------------------------------------------------------
    -- 14) Inside Closed Period → February?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodEnd AND @FebruaryEnd
        SET @IsInsideClosedPeriodToFebruary = 1;


    --------------------------------------------------------------------
    -- 15) Final Output
    --------------------------------------------------------------------
    SELECT
        @OrganicManureId AS OrganicManureId,
        @CropId AS CropId,
        @FieldId AS FieldId,
        @FarmId AS FarmId,
        @CountryId AS CountryId,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNvz AS IsWithinNvz,

        @IsAllowedManureType AS IsAllowedManureType,
        @IsPreviousApplicationWithinTwentyDays AS IsPreviousApplicationWithinTwentyDays,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,
        @FebruaryEnd AS FebruaryEnd,

        @IsInsideClosedPeriodToFebruary AS IsInsideClosedPeriodToFebruary;

END;