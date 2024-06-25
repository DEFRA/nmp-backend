﻿CREATE TABLE [dbo].[ClimateDatabase]
(
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Territory] [nvarchar](50) NOT NULL,
	[PostCode] [nvarchar](50) NOT NULL,
	[East] [int] NOT NULL,
	[North] [int] NOT NULL,
	[Altitude] [decimal](18, 9) NOT NULL,
	[MeanMinJan] [decimal](18, 9) NOT NULL,
	[MeanMinFeb] [decimal](18, 9) NOT NULL,
	[MeanMinMar] [decimal](18, 9) NOT NULL,
	[MeanMinApr] [decimal](18, 9) NOT NULL,
	[MeanMinMay] [decimal](18, 9) NOT NULL,
	[MeanMinJun] [decimal](18, 9) NOT NULL,
	[MeanMinJul] [decimal](18, 9) NOT NULL,
	[MeanMinAug] [decimal](18, 9) NOT NULL,
	[MeanMinSep] [decimal](18, 9) NOT NULL,
	[MeanMinOct] [decimal](18, 9) NOT NULL,
	[MeanMinNov] [decimal](18, 9) NOT NULL,
	[MeanMinDec] [decimal](18, 9) NOT NULL,
	[MeanMaxJan] [decimal](18, 9) NOT NULL,
	[MeanMaxFeb] [decimal](18, 9) NOT NULL,
	[MeanMaxMar] [decimal](18, 9) NOT NULL,
	[MeanMaxApr] [decimal](18, 9) NOT NULL,
	[MeanMaxMay] [decimal](18, 9) NOT NULL,
	[MeanMaxJun] [decimal](18, 9) NOT NULL,
	[MeanMaxJul] [decimal](18, 9) NOT NULL,
	[MeanMaxAug] [decimal](18, 9) NOT NULL,
	[MeanMaxSep] [decimal](18, 9) NOT NULL,
	[MeanMaxOct] [decimal](18, 9) NOT NULL,
	[MeanMaxNov] [decimal](18, 9) NOT NULL,
	[MeanMaxDec] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallJan] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallFeb] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallMar] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallApr] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallMay] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallJun] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallJul] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallAug] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallSep] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallOct] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallNov] [decimal](18, 9) NOT NULL,
	[MeanTotalRainFallDec] [decimal](18, 9) NOT NULL,
	[MeanSunHoursJan] [decimal](18, 9) NOT NULL,
	[MeanSunHoursFeb] [decimal](18, 9) NOT NULL,
	[MeanSunHoursMar] [decimal](18, 9) NOT NULL,
	[MeanSunHoursApr] [decimal](18, 9) NOT NULL,
	[MeanSunHoursMay] [decimal](18, 9) NOT NULL,
	[MeanSunHoursJun] [decimal](18, 9) NOT NULL,
	[MeanSunHoursJul] [decimal](18, 9) NOT NULL,
	[MeanSunHoursAug] [decimal](18, 9) NOT NULL,
	[MeanSunHoursSep] [decimal](18, 9) NOT NULL,
	[MeanSunHoursOct] [decimal](18, 9) NOT NULL,
	[MeanSunHoursNov] [decimal](18, 9) NOT NULL,
	[MeanSunHoursDec] [decimal](18, 9) NOT NULL,
	[MeanRainDaysJan] [decimal](18, 9) NOT NULL,
	[MeanRainDaysFeb] [decimal](18, 9) NOT NULL,
	[MeanRainDaysMar] [decimal](18, 9) NOT NULL,
	[MeanRainDaysApr] [decimal](18, 9) NOT NULL,
	[MeanRainDaysMay] [decimal](18, 9) NOT NULL,
	[MeanRainDaysJun] [decimal](18, 9) NOT NULL,
	[MeanRainDaysJul] [decimal](18, 9) NOT NULL,
	[MeanRainDaysAug] [decimal](18, 9) NOT NULL,
	[MeanRainDaysSep] [decimal](18, 9) NOT NULL,
	[MeanRainDaysOct] [decimal](18, 9) NOT NULL,
	[MeanRainDaysNov] [decimal](18, 9) NOT NULL,
	[MeanRainDaysDec] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedJan] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedFeb] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedMar] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedApr] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedMay] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedJun] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedJul] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedAug] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedSep] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedOct] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedNov] [decimal](18, 9) NOT NULL,
	[MeanWindSpeedDec] [decimal](18, 9) NOT NULL,
    CONSTRAINT [PK_ClimateDatabase] PRIMARY KEY ([ID] ASC)
)
