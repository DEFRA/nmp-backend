
CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodEndFebruaryManureRate]
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
        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        @SowingDate DATE,
        @ApplicationDate DATE,
        @ManureTypeId INT,
        @ApplicationRate DECIMAL(18,3),
        @SoilTypeId INT,

        -- Flags
        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNvz BIT = 0,
        @IsAllowedManureType BIT = 0,
        @IsApplicationRateAboveThirty BIT = 0,
        @IsInsideClosedPeriodToFebruary BIT = 0,

        -- Date helpers
        @ApplicationMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @FebruaryEnd DATE,
        @FebruaryYear INT;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate    = CAST(om.ApplicationDate AS DATE),
        @ManureTypeId       = om.ManureTypeID,
        @ApplicationRate    = ISNULL(om.ApplicationRate,0)
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;


    --------------------------------------------------------------------
    -- 2) Crop from ManagementPeriod
    --------------------------------------------------------------------
    SELECT @CropId = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodId;


    --------------------------------------------------------------------
    -- 3) Crop details
    --------------------------------------------------------------------
    SELECT
        @FieldId    = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @SowingDate = CAST(c.SowingDate AS DATE)
    FROM Crops c
    WHERE c.ID = @CropId;


    --------------------------------------------------------------------
    -- 4) Perennial flag
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = ISNULL(ctl.IsPerennial,0)
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeId;


    --------------------------------------------------------------------
    -- 5) Prior-year perennial check
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops cPrev
        INNER JOIN CropTypeLinkings ctlPrev
            ON ctlPrev.CropTypeID = cPrev.CropTypeID
        WHERE cPrev.FieldID = @FieldId
          AND cPrev.Year < YEAR(@ApplicationDate)
          AND ISNULL(ctlPrev.IsPerennial,0) = 1
    )
        SET @HasPriorYearPlantings = 1;


    --------------------------------------------------------------------
    -- 6) Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeId  = f.SoilTypeID,
        @IsWithinNvz = ISNULL(f.IsWithinNVZ,0),
        @FarmId      = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------------------
    -- 7) Farm / Country
    --------------------------------------------------------------------
    SELECT @CountryId = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmId;

    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales   = 1;


    --------------------------------------------------------------------
    -- 8) Allowed manure types
    --------------------------------------------------------------------
    IF @ManureTypeId IN (12,45,13,14,15,18)
        SET @IsAllowedManureType = 1;


    --------------------------------------------------------------------
    -- 9) Application rate check
    --------------------------------------------------------------------
    IF @ApplicationRate > 30
        SET @IsApplicationRateAboveThirty = 1;


    --------------------------------------------------------------------
    -- 10) Date helpers
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @ApplicationYear     = YEAR(@ApplicationDate);


    --------------------------------------------------------------------
    -- 11) Year Cycle (Aug → Jul)
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
    -- 12) CLOSED PERIOD LOGIC (unchanged)
    --------------------------------------------------------------------
    IF @HasPriorYearPlantings = 1
    BEGIN
        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
    END
    ELSE IF @IsPerennial = 0
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
        IF @SoilTypeId IN (0,1)
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
        ELSE
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);

        SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
    END;


    --------------------------------------------------------------------
    -- 13) FEBRUARY YEAR LOGIC (✅ UPDATED)
    --------------------------------------------------------------------
    IF MONTH(@ClosedPeriodEnd) = 12
        SET @FebruaryYear = YEAR(@ClosedPeriodEnd) + 1;
    ELSE
        SET @FebruaryYear = YEAR(@ClosedPeriodEnd);


    IF (@FebruaryYear % 4 = 0 AND @FebruaryYear % 100 <> 0)
        OR (@FebruaryYear % 400 = 0)
        SET @FebruaryEnd = DATEFROMPARTS(@FebruaryYear,2,29);
    ELSE
        SET @FebruaryEnd = DATEFROMPARTS(@FebruaryYear,2,28);


    --------------------------------------------------------------------
    -- 14) Inside Closed Period → February?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd
        SET @IsInsideClosedPeriodToFebruary = 1;


    --------------------------------------------------------------------
    -- 15) FINAL OUTPUT
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
        @IsApplicationRateAboveThirty AS IsApplicationRateAboveThirty,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,
        @FebruaryEnd AS FebruaryEnd,

        @IsInsideClosedPeriodToFebruary AS IsInsideClosedPeriodToFebruary,

        @ApplicationRate AS ApplicationRate;
END;