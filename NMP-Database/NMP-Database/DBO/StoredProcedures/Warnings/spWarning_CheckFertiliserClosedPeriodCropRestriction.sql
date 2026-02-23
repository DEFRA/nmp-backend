


CREATE PROCEDURE [dbo].[spWarning_CheckFertiliserClosedPeriodCropRestriction]
    @FertiliserID INT
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

        @ApplicationDate DATE,
        @SowingDate DATE,
        @SoilTypeID INT,

        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsFieldWithinNVZ BIT = 0,

        @IsCropTypeAllowed BIT = 0,
        @IsApplicationInsideClosedPeriod BIT = 0,

        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,

        @YearCycleStart DATE,
        @YearCycleEnd DATE,

        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE;

    --------------------------------------------------------------------
    -- 1) Load Fertiliser
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = fm.ManagementPeriodID,
        @ApplicationDate = CAST(fm.ApplicationDate AS DATE)
    FROM FertiliserManures fm
    WHERE fm.ID = @FertiliserID;

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
        @FieldID = c.FieldID,
        @CropTypeID = c.CropTypeID,
        @SowingDate = CAST(c.SowingDate AS DATE)
    FROM Crops c
    WHERE c.ID = @CropID;

    --------------------------------------------------------------------
    -- 4) Load Field (Soil + NVZ)
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @IsFieldWithinNVZ = ISNULL(f.IsWithinNVZ,0),
        @FarmID = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;

    --------------------------------------------------------------------
    -- 5) Load Farm (Country)
    --------------------------------------------------------------------
    SELECT @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;

    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWales = 1;

    --------------------------------------------------------------------
    -- 6) CropType allowed (restriction rule)
    --------------------------------------------------------------------
    IF @CropTypeID NOT IN (
        43,41,189,44,194,195,61,62,63,64,70,78,92,93,
        73,140,74,20,60
    )
        SET @IsCropTypeAllowed = 1;

    --------------------------------------------------------------------
    -- 7) Date helpers
    --------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @AppYear = YEAR(@ApplicationDate);

    SET @SowMMDD =
        CASE WHEN @SowingDate IS NULL THEN NULL
             ELSE MONTH(@SowingDate)*100 + DAY(@SowingDate)
        END;

    --------------------------------------------------------------------
    -- 8) Perennial flag
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = ISNULL(ctl.IsPerennial,0)
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeID;

    --------------------------------------------------------------------
    -- 9) Prior-year perennial crop exists
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops cprev
        INNER JOIN CropTypeLinkings ctlprev
            ON ctlprev.CropTypeID = cprev.CropTypeID
        WHERE cprev.FieldID = @FieldID
          AND cprev.Year < @AppYear
          AND ctlprev.IsPerennial = 1
    )
        SET @HasPriorYearPlantings = 1;

    --------------------------------------------------------------------
    -- 10) Year cycle (1 Aug → 31 Jul)
    --------------------------------------------------------------------
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
    -- 11) CLOSED PERIOD LOGIC (FERTILISER – FULL)
    --------------------------------------------------------------------
    SET @ClosedPeriodStart = NULL;
    SET @ClosedPeriodEnd   = NULL;

    IF @CropTypeID = 140
    BEGIN
        -- GRASS
        IF @SoilTypeID IN (0,1)
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,15);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
        ELSE
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,15);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
    END
    ELSE
    BEGIN
        -- NON-GRASS
        IF @HasPriorYearPlantings = 1
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
        ELSE IF @IsPerennial = 1
        BEGIN
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
        ELSE
        BEGIN
            -- NON-PERENNIAL
            SET @ClosedPeriodStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
            SET @ClosedPeriodEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
    END

    --------------------------------------------------------------------
    -- 12) Application inside closed period?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @ClosedPeriodEnd
        SET @IsApplicationInsideClosedPeriod = 1;

    --------------------------------------------------------------------
    -- 13) FINAL OUTPUT
    --------------------------------------------------------------------
    SELECT
        @FertiliserID AS FertiliserID,
        @FieldID AS FieldID,
        @CropID AS CropID,
        @CropTypeID AS CropTypeID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsFieldWithinNVZ AS IsFieldWithinNVZ,

        @IsCropTypeAllowed AS IsCropTypeAllowed,
        @IsApplicationInsideClosedPeriod AS IsApplicationInsideClosedPeriod,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd;
END;