

CREATE PROCEDURE [dbo].[spWarning_CheckFertiliserClosedPeriodCropRestriction]
    @FertiliserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------
    -- DECLARE VARIABLES
    -------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,

        @ApplicationDate DATETIME,
        @SowingDate DATETIME,
        @SoilTypeID INT,

        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsFieldWithinNVZ BIT = 0,

        @IsApplicationInsideClosedPeriod BIT = 0,
        @IsCropTypeAllowed BIT = 0,

        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,

        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedStartDate DATE,
        @ClosedEndDate DATE;

    -------------------------------------------------------------------
    -- 1) Load Fertiliser
    -------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = f.ManagementPeriodID,
        @ApplicationDate = f.ApplicationDate
    FROM Fertilisers f
    WHERE f.ID = @FertiliserID;

    -------------------------------------------------------------------
    -- 2) ManagementPeriod → Crop
    -------------------------------------------------------------------
    SELECT @CropID = mp.CropID
    FROM ManagementPeriods mp
    WHERE mp.ID = @ManagementPeriodID;

    -------------------------------------------------------------------
    -- 3) Load Crop
    -------------------------------------------------------------------
    SELECT 
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropID;

    -------------------------------------------------------------------
    -- 4) Load Field (NOW ALSO LOAD NVZ FLAG)
    -------------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @FarmID = f.FarmID,
        @IsFieldWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ, 0) = 1 THEN 1 ELSE 0 END
    FROM Fields f
    WHERE f.ID = @FieldID;

    -------------------------------------------------------------------
    -- 5) Load Farm
    -------------------------------------------------------------------
    SELECT 
        @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    -------------------------------------------------------------------
    -- 6) Country flags
    -------------------------------------------------------------------
    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWales = 1;

    -------------------------------------------------------------------
    -- 7) CropType Allowed?
    -- Allowed = NOT IN the excluded list
    -------------------------------------------------------------------
    IF @CropTypeID NOT IN (
        43,41,189,44,194,195,61,62,63,64,70,78,92,93,73,140,74,0,60
    )
         SET @IsCropTypeAllowed = 1;
    ELSE SET @IsCropTypeAllowed = 0;

    -------------------------------------------------------------------
    -- 8) Date Helpers
    -------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);

    IF @SowingDate IS NOT NULL
        SET @SowMMDD = MONTH(@SowingDate)*100 + DAY(@SowingDate);
    ELSE 
        SET @SowMMDD = NULL;

    -------------------------------------------------------------------
    -- 9) Load Perennial
    -------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    -------------------------------------------------------------------
    -- 10) Prior Year Perennial Crop Exists?
    -------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops cprev
        INNER JOIN CropTypeLinkings ctprev ON ctprev.CropTypeID = cprev.CropTypeID
        WHERE cprev.FieldID = @FieldID
          AND cprev.Year < YEAR(@ApplicationDate)
          AND ISNULL(ctprev.IsPerennial,0) = 1
    )
        SET @HasPriorYearPlantings = 1;

    -------------------------------------------------------------------
    -- 11) Year cycle: 1 Aug → 31 Jul
    -------------------------------------------------------------------
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

    -------------------------------------------------------------------
    -- 12) CLOSED PERIOD LOGIC (unchanged per your rule)
    -------------------------------------------------------------------
    SET @ClosedStartDate = NULL;
    SET @ClosedEndDate = NULL;

    ------------------------------------------------------------
    -- A) PRIOR YEAR PERENNIAL → 1 SEP – 15 JAN
    ------------------------------------------------------------
    IF @HasPriorYearPlantings = 1
    BEGIN
        SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
        SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
    END
    ELSE
    BEGIN
        ------------------------------------------------------------
        -- B) CURRENT CROP GRASS (140) → 15 SEP – 15 JAN
        ------------------------------------------------------------
        IF @CropTypeID = 140
        BEGIN
            SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,15);
            SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
        ELSE
        BEGIN
            ------------------------------------------------------------
            -- C) NON-GRASS LOGIC
            ------------------------------------------------------------
            IF @IsPerennial = 0  -- NON-PERENNIAL
            BEGIN
                -- ALL NON-PERENNIAL → 1 SEP – 15 JAN
                SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
            END
            ELSE
            BEGIN
                -- PERENNIAL CURRENT YEAR → 1 SEP – 15 JAN
                SET @ClosedStartDate = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                SET @ClosedEndDate   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
            END
        END
    END

    -------------------------------------------------------------------
    -- 13) Is Application Inside Closed Period?
    -------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedStartDate AND @ClosedEndDate
         SET @IsApplicationInsideClosedPeriod = 1;

    -------------------------------------------------------------------
    -- 14) Final Output
    -------------------------------------------------------------------
    SELECT
        @FertiliserID AS FertiliserID,
        @FieldID AS FieldID,
        @CropID AS CropID,
        @CropTypeID AS CropTypeID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsFieldWithinNVZ AS IsFieldWithinNVZ,

        @IsApplicationInsideClosedPeriod AS IsApplicationInsideClosedPeriod,
        @IsCropTypeAllowed AS IsCropTypeAllowed,

        @ClosedStartDate AS ClosedPeriodStart,
        @ClosedEndDate AS ClosedPeriodEnd;

END;