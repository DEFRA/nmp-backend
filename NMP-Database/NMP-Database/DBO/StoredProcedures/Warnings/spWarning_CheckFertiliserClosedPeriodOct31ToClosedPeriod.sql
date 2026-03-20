



CREATE PROCEDURE [dbo].[spWarning_CheckFertiliserClosedPeriodOct31ToClosedPeriod]
    @FertiliserID INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------------
    -- DECLARE VARIABLES
    --------------------------------------------------------------------
    DECLARE
        @ManagementPeriodID INT,
        @CropID INT,
        @FieldID INT,
        @FarmID INT,
        @CountryID INT,
        @CropTypeID INT,
        @SoilTypeID INT,

        @ApplicationDate DATETIME,
        @SowingDate DATETIME,

        @IsFieldInEngland BIT = 0,
        @IsFieldInWales BIT = 0,
        @IsWithinNVZ BIT = 0,

        @IsGrassCropType BIT = 0,
        @IsWinterOilSeedRapeCropType BIT = 0,

        @IsPerennial BIT = 0,
        @HasPriorYearPlantings BIT = 0,

        @AppMMDD INT,
        @SowMMDD INT,
        @AppYear INT,

        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedStart DATE,
        @ClosedEnd DATE,
        @October31 DATE,

        @IsInsidePeriod BIT = 0;


    --------------------------------------------------------------------
    -- 1) Load Fertiliser
    --------------------------------------------------------------------
    SELECT
        @ManagementPeriodID = f.ManagementPeriodID,
        @ApplicationDate = f.ApplicationDate
    FROM FertiliserManures f
    WHERE f.ID = @FertiliserID;


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
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropID;


    --------------------------------------------------------------------
    -- 4) Identify crop type
    --------------------------------------------------------------------
    IF @CropTypeID = 140 SET @IsGrassCropType = 1;
    IF @CropTypeID = 20  SET @IsWinterOilSeedRapeCropType = 1;


    --------------------------------------------------------------------
    -- 5) Load Field
    --------------------------------------------------------------------
    SELECT
        @SoilTypeID = f.SoilTypeID,
        @IsWithinNVZ = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmID = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldID;


    --------------------------------------------------------------------
    -- 6) Load Farm
    --------------------------------------------------------------------
    SELECT @CountryID = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmID;


    --------------------------------------------------------------------
    -- 7) Flags for England / Wales
    --------------------------------------------------------------------
    IF @CountryID = 1 SET @IsFieldInEngland = 1;
    IF @CountryID = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------------------
    -- 8) Prepare dates
    --------------------------------------------------------------------
    SET @AppMMDD = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);

    IF @SowingDate IS NOT NULL
         SET @SowMMDD = MONTH(@SowingDate)*100 + DAY(@SowingDate);


    --------------------------------------------------------------------
    -- 9) Perennial lookup
    --------------------------------------------------------------------
    SELECT TOP 1
        @IsPerennial =
            CASE WHEN ISNULL(IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings
    WHERE CropTypeID = @CropTypeID;


    --------------------------------------------------------------------
    -- 10) Prior year crops exist?
    --------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM Crops WHERE FieldID=@FieldID AND Year < YEAR(@ApplicationDate))
        SET @HasPriorYearPlantings = 1;


    --------------------------------------------------------------------
    -- 11) Year Cycle 1 Aug → 31 July
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
    -- 12) FULL CLOSED PERIOD LOGIC (grass / perennial / non-perennial)
    --------------------------------------------------------------------
    SET @ClosedStart = NULL;
    SET @ClosedEnd = NULL;

    IF @CropTypeID = 140
    BEGIN
        -- Grass rules
        IF @SoilTypeID IN (0,1)
        BEGIN
            SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,15);
            SET @ClosedEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
        ELSE
        BEGIN
            SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,15);
            SET @ClosedEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
        END
    END
    ELSE
    BEGIN
        -- Non-grass logic
        IF @IsPerennial = 0
        BEGIN
            IF @SoilTypeID IN (0,1)
            BEGIN
                IF @SowMMDD IS NULL OR @SowMMDD >= 916
                    SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                ELSE
                    SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);

                SET @ClosedEnd = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
            END
            ELSE
            BEGIN
                SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                SET @ClosedEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
            END
        END
        ELSE
        BEGIN
            -- Perennial
            IF @SoilTypeID IN (0,1)
            BEGIN
                SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                SET @ClosedEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);

                IF @HasPriorYearPlantings = 1
                BEGIN
                    SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                    SET @ClosedEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
                END
            END
            ELSE
            BEGIN
                SET @ClosedStart = DATEFROMPARTS(YEAR(@YearCycleStart),9,1);
                SET @ClosedEnd   = DATEFROMPARTS(YEAR(@YearCycleStart)+1,1,15);
            END
        END
    END;


    --------------------------------------------------------------------
    -- 13) October 31 date
    --------------------------------------------------------------------
    SET @October31 = DATEFROMPARTS(YEAR(@ClosedStart),10,31);


    --------------------------------------------------------------------
    -- 14) Application between Oct 31 and ClosedPeriodEnd?
    --------------------------------------------------------------------
    IF @ApplicationDate BETWEEN @October31 AND @ClosedEnd
        SET @IsInsidePeriod = 1;


    --------------------------------------------------------------------
    -- 15) Final Return
    --------------------------------------------------------------------
    SELECT
        @FertiliserID AS FertiliserID,
        @FieldID AS FieldID,
        @CropID AS CropID,
        @CropTypeID AS CropTypeID,

        @IsFieldInEngland AS IsFieldInEngland,
        @IsFieldInWales AS IsFieldInWales,
        @IsWithinNVZ AS IsWithinNVZ,

        @IsGrassCropType AS IsGrassCropType,
        @IsWinterOilSeedRapeCropType AS IsWinterOilSeedRapeCropType,

        @IsInsidePeriod AS IsApplicationInsideOct31ToClosedPeriod,

        @October31 AS October31Date,
        @ClosedStart AS ClosedPeriodStart,
        @ClosedEnd AS ClosedPeriodEnd;
END;