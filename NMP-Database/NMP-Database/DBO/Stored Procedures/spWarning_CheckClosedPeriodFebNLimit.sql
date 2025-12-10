

CREATE   PROCEDURE [dbo].[spWarning_CheckClosedPeriodFebNLimit]
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

        @IsHighRanManures BIT = 0,

        @AppMMDD INT,
        @SowMMDD INT,

        @AppYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,

        @ClosedStartDate DATE,
        @ClosedEndDate DATE,
        @FebEnd DATE,

        @IsWithinClosedPeriod BIT = 0,
        @IsWithinClosedPeriodToFeb BIT = 0,

        @TotalClosedPeriodN DECIMAL(18,3) = 0,

        -- NEW FLAGS
        @IsAllowedCrop BIT = 0,
        @IsTotalClosedPeriodNAboveLimit BIT = 0;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = om.ManagementPeriodID,
        @ApplicationDate    = om.ApplicationDate,
        @ManureTypeID       = om.ManureTypeID,
        @N                  = om.N
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureID;


    --------------------------------------------------------------------
    -- 2) ManagementPeriod → Crop
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
    -- 3.a) Determine if crop type is allowed
    --      Allowed cropTypeIDs: (0, 60, 73, 74)
    --------------------------------------------------------------------
    SET @IsAllowedCrop = CASE WHEN @CropTypeID IN (0,60,73,74) THEN 1 ELSE 0 END;


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
    -- 5) Load Farm
    --------------------------------------------------------------------
    SELECT
        @CountryID = fm.CountryID,
        @RegisteredOrganicProducer =
            CASE WHEN ISNULL(fm.RegisteredOrganicProducer,0)=1 THEN 1 ELSE 0 END
    FROM Farms fm
    WHERE fm.ID = @FarmID;


    --------------------------------------------------------------------
    -- 6) Country Flags
    --------------------------------------------------------------------
    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWelsh   = 1;


    --------------------------------------------------------------------
    -- 7) High RAN Manures
    --------------------------------------------------------------------
    IF @ManureTypeID IN (8,12,13,14,15,18,45,46,49,51)
        SET @IsHighRanManures = 1;
    ELSE
        SET @IsHighRanManures = 0;


    --------------------------------------------------------------------
    -- If crop is not allowed -> return early but include flags (totals remain 0)
    --------------------------------------------------------------------
    IF @IsAllowedCrop = 0
    BEGIN
        SELECT
            @OrganicManureID AS OrganicManureID,
            @ManagementPeriodID AS ManagementPeriodID,
            @CropID AS CropID,
            @FieldID AS FieldID,
            @FarmID AS FarmID,

            @IsFieldInEngland AS IsFieldInEngland,
            @IsFieldInWelsh AS IsFieldInWelsh,
            @IsWithinNVZ AS IsWithinNVZ,
            @RegisteredOrganicProducer AS RegisteredOrganicProducer,

            @CropTypeID AS CropTypeID,
            @SoilTypeID AS SoilTypeID,

            @ApplicationDate AS ApplicationDate,
            NULL AS ClosedPeriodStart,
            NULL AS ClosedPeriodEnd,
            NULL AS FebEnd,

            @IsHighRanManures AS IsHighRanManures,
            0 AS InsideClosedPeriod,
            0 AS InsideClosedPeriodToFeb,

            @N AS CurrentManureN,
            0 AS TotalClosedPeriodN,

            @IsAllowedCrop AS IsAllowedCrop,
            0 AS IsTotalClosedPeriodNAboveLimit;
        RETURN;
    END


    --------------------------------------------------------------------
    -- 8) Convert Dates to MMDD
    --------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);

    IF @SowingDate IS NOT NULL
        SET @SowMMDD = MONTH(@SowingDate)*100 + DAY(@SowingDate);
    ELSE
        SET @SowMMDD = NULL;


    --------------------------------------------------------------------
    -- 9) Perennial Flag
    --------------------------------------------------------------------
    SELECT TOP(1)
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    IF @IsPerennial IS NULL SET @IsPerennial = 0;


    --------------------------------------------------------------------
    -- 10) Prior-year Planting Check
    --------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM Crops cprev
               WHERE cprev.FieldID=@FieldID AND cprev.Year < @CropYear)
         SET @HasPriorYearPlantings = 1;
    ELSE SET @HasPriorYearPlantings = 0;


    --------------------------------------------------------------------
    -- 11) Year-cycle: 1 Aug → 31 July
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
    SET @ClosedEndDate   = NULL;

    IF @CropTypeID = 140 -- Grass logic
    BEGIN
        IF @SoilTypeID IN (11,12)
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
        -- Non-grass logic
        IF @IsPerennial = 0
        BEGIN
            IF @SoilTypeID IN (11,12)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                     SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                ELSE SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);

                SET @ClosedEndDate = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
            END
            ELSE
            BEGIN
                SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);
                SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,31);
            END
        END
        ELSE
        BEGIN
            IF @SoilTypeID IN (11,12)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                     SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
                ELSE SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,16);

                SET @ClosedEndDate = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);

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
    -- 13) Inside Closed Period
    --------------------------------------------------------------------
    SET @IsWithinClosedPeriod =
        CASE WHEN @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
             THEN 1 ELSE 0 END;


    --------------------------------------------------------------------
    -- 14) End of February (Leap-year aware)
    --------------------------------------------------------------------
    IF (YEAR(@ApplicationDate) % 4 = 0 AND YEAR(@ApplicationDate) % 100 <> 0)
         OR (YEAR(@ApplicationDate) % 400 = 0)
        SET @FebEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,29);
    ELSE
        SET @FebEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,28);


    --------------------------------------------------------------------
    -- 15) Application inside Closed Period → February
    --------------------------------------------------------------------
    SET @IsWithinClosedPeriodToFeb = 0;

    IF @IsWithinClosedPeriod = 1
        IF @ApplicationDate BETWEEN @ClosedStartDate AND @FebEnd
            SET @IsWithinClosedPeriodToFeb = 1;


    --------------------------------------------------------------------
    -- 16) SUM N OF ALL OM IN SAME MANAGEMENT PERIOD WITHIN CLOSED→FEB
    --      Now using N * ApplicationRate (and only if crop allowed)
    --------------------------------------------------------------------
    IF @IsAllowedCrop = 1
    BEGIN
        SELECT 
            @TotalClosedPeriodN = ISNULL(SUM(om2.N * ISNULL(om2.ApplicationRate,0)),0)
        FROM OrganicManures om2
        WHERE om2.ManagementPeriodID = @ManagementPeriodID
          AND om2.ApplicationDate BETWEEN @ClosedStartDate AND @FebEnd;
    END
    ELSE
        SET @TotalClosedPeriodN = 0;


    IF @TotalClosedPeriodN IS NULL SET @TotalClosedPeriodN = 0;


    --------------------------------------------------------------------
    -- 17) Check > 150 (only if allowed crop)
    --------------------------------------------------------------------
    SET @IsTotalClosedPeriodNAboveLimit =
        CASE WHEN @IsAllowedCrop = 1 AND @TotalClosedPeriodN > 150 THEN 1 ELSE 0 END;


    --------------------------------------------------------------------
    -- 18) FINAL OUTPUT
    --------------------------------------------------------------------
    SELECT
        @OrganicManureID AS OrganicManureID,
        @ManagementPeriodID AS ManagementPeriodID,
        @CropID AS CropID,
        @FieldID AS FieldID,
        @FarmID AS FarmID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWelsh AS IsFieldInWelsh,
        @IsWithinNVZ AS IsWithinNVZ,
        @RegisteredOrganicProducer AS RegisteredOrganicProducer,

        @CropTypeID AS CropTypeID,
        @SoilTypeID AS SoilTypeID,

        @ApplicationDate AS ApplicationDate,
        @ClosedStartDate AS ClosedPeriodStart,
        @ClosedEndDate AS ClosedPeriodEnd,
        @FebEnd AS FebEnd,

        @IsHighRanManures AS IsHighRanManures,
        @IsWithinClosedPeriod AS InsideClosedPeriod,
        @IsWithinClosedPeriodToFeb AS InsideClosedPeriodToFeb,

        @N AS CurrentManureN,
        @TotalClosedPeriodN AS TotalClosedPeriodN,

        @IsAllowedCrop AS IsAllowedCrop,
        @IsTotalClosedPeriodNAboveLimit AS IsTotalClosedPeriodNAboveLimit;
END;