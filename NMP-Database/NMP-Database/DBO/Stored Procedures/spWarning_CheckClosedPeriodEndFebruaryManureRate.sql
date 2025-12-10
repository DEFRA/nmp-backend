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

        @SowingDate DATETIME,
        @ApplicationDate DATETIME,
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

        -- Dates
        @ApplicationMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @FebruaryEnd DATE;


    --------------------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = om.ApplicationDate,
        @ManureTypeId = om.ManureTypeID,
        @ApplicationRate = om.ApplicationRate
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;


    --------------------------------------------------------------------
    -- 2) Get CropId from ManagementPeriod
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
    -- 4) PERENNIAL FLAG FROM CropTypeLinkings
    --------------------------------------------------------------------
    SELECT TOP 1 @IsPerennial = ISNULL(ctl.IsPerennial,0)
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeId;


    --------------------------------------------------------------------
    -- 5) PRIOR YEAR PERENNIAL CHECK
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops cPrev
        INNER JOIN CropTypeLinkings ctlPrev ON ctlPrev.CropTypeID = cPrev.CropTypeID
        WHERE cPrev.FieldID = @FieldId
          AND cPrev.Year < YEAR(@ApplicationDate)
          AND ISNULL(ctlPrev.IsPerennial,0) = 1
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
    -- 7) Load Farm (Country flags)
    --------------------------------------------------------------------
    SELECT @CountryId = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmId;

    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------------------
    -- 8) Allowed Manure Types
    --------------------------------------------------------------------
    IF @ManureTypeId IN (12,45,13,14,15,18)
        SET @IsAllowedManureType = 1;
    ELSE
        SET @IsAllowedManureType = 0;


    --------------------------------------------------------------------
    -- 9) Application Rate > 30?
    --------------------------------------------------------------------
    IF @ApplicationRate > 30
        SET @IsApplicationRateAboveThirty = 1;
    ELSE
        SET @IsApplicationRateAboveThirty = 0;


    --------------------------------------------------------------------
    -- 10) Date Helpers
    --------------------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @ApplicationYear = YEAR(@ApplicationDate);


    --------------------------------------------------------------------
    -- 11) Year Cycle (Aug 1 → Jul 31)
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
    -- 12) CLOSED PERIOD LOGIC — UPDATED WITH PERENNIAL RULES
    --------------------------------------------------------------------

    -------------------------------
    -- CASE 1: PRIOR YEAR PERENNIAL
    -------------------------------
    IF @HasPriorYearPlantings = 1
    BEGIN
        SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
        SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
    END
    ELSE
    -------------------------------
    -- CASE 2: NON-PERENNIAL CROPS
    -------------------------------
    IF @IsPerennial = 0
    BEGIN
        IF @SoilTypeId IN (11,12)
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
    -------------------------------
    -- CASE 3: PERENNIAL CURRENT CROP
    -------------------------------
    BEGIN
        IF @SoilTypeId IN (11,12)
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),8,1);
        ELSE
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),10,1);

        SET @ClosedPeriodEnd = DATEFROMPARTS(YEAR(@YearCycleStart),12,31);
    END;


    --------------------------------------------------------------------
    -- 13) End of February Boundary (Leap aware)
    --------------------------------------------------------------------
    IF (YEAR(@ApplicationDate) % 4 = 0 AND YEAR(@ApplicationDate) % 100 <> 0)
         OR (YEAR(@ApplicationDate) % 400 = 0)
        SET @FebruaryEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,29);
    ELSE
        SET @FebruaryEnd = DATEFROMPARTS(YEAR(@ApplicationDate),2,28);


    --------------------------------------------------------------------
    -- 14) Inside Closed Period → February?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd
        SET @IsInsideClosedPeriodToFebruary = 1;
    ELSE
        SET @IsInsideClosedPeriodToFebruary = 0;


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