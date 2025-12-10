CREATE PROCEDURE [dbo].[spWarning_CheckClosedPeriodEndFebruaryPoultryManure]
    @OrganicManureId INT
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------
    -- DECLARE VARIABLES
    --------------------------------------------------------
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
        @ApplicationMonthDay INT,
        @ApplicationYear INT,
        @YearCycleStart DATE,
        @YearCycleEnd DATE,
        @ClosedPeriodStart DATE,
        @ClosedPeriodEnd DATE,
        @FebruaryEnd DATE,
        @SowMMDD INT;


    --------------------------------------------------------
    -- 1) Load Organic Manure
    --------------------------------------------------------
    SELECT
        @ManagementPeriodId = om.ManagementPeriodID,
        @ApplicationDate = om.ApplicationDate,
        @ManureTypeId = om.ManureTypeID,
        @ApplicationRate = om.ApplicationRate
    FROM OrganicManures om
    WHERE om.ID = @OrganicManureId;


    --------------------------------------------------------
    -- 2) Load Crop
    --------------------------------------------------------
    SELECT
        @FieldId = c.FieldID,
        @CropTypeId = c.CropTypeID,
        @SowingDate = c.SowingDate
    FROM Crops c
    WHERE c.ID = @CropId;


    --------------------------------------------------------
    -- 3) Perennial flag from CropTypeLinkings
    --------------------------------------------------------
    SELECT TOP 1
        @IsPerennial = CASE WHEN ISNULL(ctl.IsPerennial,0)=1 THEN 1 ELSE 0 END
    FROM CropTypeLinkings ctl
    WHERE ctl.CropTypeID = @CropTypeId;


    --------------------------------------------------------
    -- 4) Prior year perennial?
    --------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM Crops c2
        INNER JOIN CropTypeLinkings ctl2 ON ctl2.CropTypeID = c2.CropTypeID
        WHERE c2.FieldID = @FieldId
          AND c2.Year < YEAR(@ApplicationDate)
          AND ctl2.IsPerennial = 1
    )
        SET @HasPriorYearPlantings = 1;


    --------------------------------------------------------
    -- 5) Load Field & NVZ
    --------------------------------------------------------
    SELECT
        @SoilTypeId = f.SoilTypeID,
        @IsWithinNvz = CASE WHEN ISNULL(f.IsWithinNVZ,0)=1 THEN 1 ELSE 0 END,
        @FarmId = f.FarmID
    FROM Fields f
    WHERE f.ID = @FieldId;


    --------------------------------------------------------
    -- 6) Farm → Country
    --------------------------------------------------------
    SELECT @CountryId = fm.CountryID
    FROM Farms fm
    WHERE fm.ID = @FarmId;

    IF @CountryId = 1 SET @IsFieldInEngland = 1;
    IF @CountryId = 3 SET @IsFieldInWales = 1;


    --------------------------------------------------------
    -- 7) Allowed poultry (ONLY 8)
    --------------------------------------------------------
    IF @ManureTypeId = 8 SET @IsAllowedPoultryManure = 1;


    --------------------------------------------------------
    -- 8) Rate > 8?
    --------------------------------------------------------
    IF @ApplicationRate > 8 SET @IsApplicationRateAboveEight = 1;


    --------------------------------------------------------
    -- 9) Date helpers
    --------------------------------------------------------
    SET @ApplicationMonthDay = MONTH(@ApplicationDate)*100 + DAY(@ApplicationDate);
    SET @ApplicationYear = YEAR(@ApplicationDate);

    IF @SowingDate IS NOT NULL
        SET @SowMMDD = MONTH(@SowingDate)*100 + DAY(@SowingDate);


    --------------------------------------------------------
    -- 10) Year Cycle
    --------------------------------------------------------
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


    --------------------------------------------------------
    -- 11) CLOSED PERIOD LOGIC (Correct Full Rules)
    --------------------------------------------------------

    IF @CropTypeId = 140   -- GRASS RULES
    BEGIN
        IF @SoilTypeId IN (11,12)
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
        IF @HasPriorYearPlantings = 1 OR @IsPerennial = 1
        BEGIN
            -- Perennial rule
            IF @SoilTypeId IN (11,12)
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
            -- Non-perennial
            IF @SoilTypeId IN (11,12)
            BEGIN
                IF @SowingDate IS NULL OR @SowMMDD >= 916
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
    -- 12) End of February
    --------------------------------------------------------
    SET @FebruaryEnd =
        CASE 
            WHEN (YEAR(@ApplicationDate)%4=0 AND YEAR(@ApplicationDate)%100<>0)
                 OR (YEAR(@ApplicationDate)%400=0)
            THEN DATEFROMPARTS(YEAR(@ApplicationDate),2,29)
            ELSE DATEFROMPARTS(YEAR(@ApplicationDate),2,28)
        END;


    --------------------------------------------------------
    -- 13) Inside closed period?
    --------------------------------------------------------
    IF @ApplicationDate BETWEEN @ClosedPeriodStart AND @FebruaryEnd
        SET @IsInsideClosedPeriodToFebruary = 1;


    --------------------------------------------------------
    -- 14) OUTPUT
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

        @IsAllowedPoultryManure AS IsAllowedPoultryManure,
        @IsApplicationRateAboveEight AS IsApplicationRateAboveEight,

        @ClosedPeriodStart AS ClosedPeriodStart,
        @ClosedPeriodEnd AS ClosedPeriodEnd,
        @FebruaryEnd AS FebruaryEnd,

        @IsInsideClosedPeriodToFebruary AS IsInsideClosedPeriodToFebruary;

END;