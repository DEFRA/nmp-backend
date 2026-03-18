CREATE PROCEDURE [dbo].[spWarning_GetOrganicManureClosedPeriod]
(
    @SoilTypeID INT,
    @FieldType INT,
    @HarvestYear INT,
    @SowingDate DATE = NULL,
    @CountryId INT,
    @CropGroupId INT = NULL,
    @CropTypeId INT = NULL,
    @IsPerennial BIT = 0
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @ClosedPeriod NVARCHAR(100)

    DECLARE @September16 DATE = DATEFROMPARTS(@HarvestYear-1,9,16)
    DECLARE @October1 DATE = DATEFROMPARTS(@HarvestYear-1,10,1)

    ------------------------------------------------
    -- Identify Sandy/Shallow Soil based on country
    ------------------------------------------------
    DECLARE @IsSandyShallowSoil BIT

    IF @CountryId = 2
    BEGIN
        IF @SoilTypeID IN (10,11,12)
            SET @IsSandyShallowSoil = 1
        ELSE
            SET @IsSandyShallowSoil = 0
    END
    ELSE
    BEGIN
        IF @SoilTypeID IN (0,1)
            SET @IsSandyShallowSoil = 1
        ELSE
            SET @IsSandyShallowSoil = 0
    END


    ------------------------------------------------
    -- SCOTLAND RULES
    ------------------------------------------------
    IF @CountryId = 2
    BEGIN

        -- GRASS
        IF @FieldType = 2
        BEGIN
            IF @IsSandyShallowSoil = 1
                SET @ClosedPeriod = '1 September to 31 December'
            ELSE
                SET @ClosedPeriod = '15 October to 31 January'
        END


        -- ARABLE
        IF @FieldType = 1
        BEGIN

            IF @IsSandyShallowSoil = 1
            BEGIN

                -- cereals
                IF @CropGroupId = 0
                BEGIN
                    IF @SowingDate IS NULL
                       OR @SowingDate >= @September16
                        SET @ClosedPeriod = '1 August to 31 December'
                    ELSE
                        SET @ClosedPeriod = '16 September to 31 December'
                END


                -- winter oilseed rape
                ELSE IF @CropTypeId = 20
                BEGIN
                    IF @SowingDate IS NULL
                       OR @SowingDate >= @October1
                        SET @ClosedPeriod = '1 August to 31 December'
                    ELSE
                        SET @ClosedPeriod = '1 October to 31 December'
                END


                -- other crops
                ELSE
                BEGIN
                    SET @ClosedPeriod = '1 August to 31 December'
                END

            END
            ELSE
            BEGIN
                SET @ClosedPeriod = '1 October to 31 January'
            END

        END

    END


    ------------------------------------------------
    -- ENGLAND / WALES RULES
    ------------------------------------------------
    ELSE
    BEGIN

        -- GRASS
        IF @FieldType = 2
        BEGIN

            IF @IsSandyShallowSoil = 1
                SET @ClosedPeriod = '1 September to 31 December'

            ELSE IF @CountryId = 3
                SET @ClosedPeriod = '15 October to 15 January'

            ELSE
                SET @ClosedPeriod = '15 October to 31 January'

        END


        -- ARABLE
        IF @FieldType = 1
        BEGIN

            IF @IsPerennial = 1
               AND @SowingDate IS NOT NULL
               AND YEAR(@SowingDate) < @HarvestYear
            BEGIN

                IF @IsSandyShallowSoil = 1
                    SET @ClosedPeriod = '16 September to 31 December'
                ELSE
                    SET @ClosedPeriod = '1 October to 31 January'

            END

            ELSE IF @IsSandyShallowSoil = 1
            BEGIN

                IF @SowingDate IS NULL
                   OR @SowingDate >= @September16
                    SET @ClosedPeriod = '1 August to 31 December'
                ELSE
                    SET @ClosedPeriod = '16 September to 31 December'

            END

            ELSE
            BEGIN
                SET @ClosedPeriod = '1 October to 31 January'
            END

        END

    END


    SELECT @ClosedPeriod AS ClosedPeriod

END
