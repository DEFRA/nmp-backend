CREATE PROCEDURE [dbo].[spWarning_GetFertiliserManureClosedPeriod]
(
    @CountryId INT,
    @CropTypeId INT,
    @NvzId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @ClosedPeriod NVARCHAR(100)

    ------------------------------------------------
    -- ENGLAND / WALES
    ------------------------------------------------
    IF @CountryId IN (1,3)
    BEGIN

        -- Grass
        IF @CropTypeId = 1
            SET @ClosedPeriod = '15 September to 15 January'

        -- Other crops
        ELSE
            SET @ClosedPeriod = '1 September to 15 January'

    END


    ------------------------------------------------
    -- SCOTLAND
    ------------------------------------------------
    ELSE IF @CountryId = 2
    BEGIN

        ------------------------------------------------
        -- Moray, Aberdeenshire/Banff and Buchan
        ------------------------------------------------
        IF @NvzId = 6
        BEGIN
            IF @CropTypeId = 1
                SET @ClosedPeriod = '15 September to 20 February'
            ELSE
                SET @ClosedPeriod = '1 September to 20 February'
        END


        ------------------------------------------------
        -- Other Scottish NVZ areas
        ------------------------------------------------
        ELSE IF @NvzId IN (3,4,5,7)
        BEGIN
            IF @CropTypeId = 1
                SET @ClosedPeriod = '15 September to 15 February'
            ELSE
                SET @ClosedPeriod = '1 September to 15 February'
        END

    END


    SELECT @ClosedPeriod AS ClosedPeriod

END