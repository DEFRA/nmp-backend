CREATE TABLE [dbo].[ScotlandGrassNMaxValues]
(
	[SwardTypeID] INT NOT NULL,
	[SwardManagementID] INT NOT NULL,
	[DefoliationSequenceID] INT NOT NULL,
	[SiteClass1] INT NOT NULL,
	[SiteClass2] INT NOT NULL,
	[SiteClass3] INT NOT NULL,
	[SiteClass4] INT NOT NULL,
	[SiteClass5] INT NOT NULL,
	CONSTRAINT [UQ_ScotlandGrassNMaxValues_SwardTypeID_SwardManagementID_DefoliationSequenceID] UNIQUE ([SwardTypeID],[SwardManagementID],[DefoliationSequenceID])

)
