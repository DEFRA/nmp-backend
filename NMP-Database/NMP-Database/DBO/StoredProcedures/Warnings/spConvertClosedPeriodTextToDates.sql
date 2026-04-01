

CREATE PROCEDURE [dbo].[spConvertClosedPeriodTextToDates]
(
    @ClosedPeriodText NVARCHAR(100),
    @HarvestYear INT
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE
    @StartText NVARCHAR(50),
    @EndText NVARCHAR(50),
    @ClosedStartDate DATE,
    @ClosedEndDate DATE,
    @StartYear INT,
    @EndYear INT;

------------------------------------------------
-- Split text
------------------------------------------------
SET @StartText =
    LEFT(@ClosedPeriodText, CHARINDEX('to',@ClosedPeriodText)-2);

SET @EndText =
    LTRIM(RTRIM(SUBSTRING(@ClosedPeriodText,
        CHARINDEX('to',@ClosedPeriodText)+2,50)));

------------------------------------------------
-- Default years
------------------------------------------------
SET @StartYear = @HarvestYear;
SET @EndYear = @HarvestYear - 1;

------------------------------------------------
-- Convert start date
------------------------------------------------
SET @ClosedStartDate =
    TRY_CONVERT(date, @StartText + ' ' + CAST(@StartYear AS VARCHAR));

------------------------------------------------
-- Convert end date
------------------------------------------------
SET @ClosedEndDate =
    TRY_CONVERT(date, @EndText + ' ' + CAST(@EndYear AS VARCHAR));

------------------------------------------------
-- If period crosses year boundary
------------------------------------------------
IF MONTH(@ClosedEndDate) <= MONTH(@ClosedStartDate)
BEGIN
    SET @ClosedEndDate =
        TRY_CONVERT(date, @EndText + ' ' + CAST(@HarvestYear + 1 AS VARCHAR));
END

------------------------------------------------
-- Output
------------------------------------------------
SELECT
    @ClosedPeriodText AS ClosedPeriod,
    @ClosedStartDate AS ClosedStartDate,
    @ClosedEndDate AS ClosedEndDate;

END