USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LibAflUpdate_BKP_LIB_ModelAttributeProperties]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LibAflUpdate_BKP_LIB_ModelAttributeProperties](
	[MAP_ID] [int] IDENTITY(1,1) NOT NULL,
	[MAP_MA_MOD_ID] [varchar](100) NOT NULL,
	[MAP_MA_DZT_Name] [varchar](100) NOT NULL,
	[MAP_Propety] [varchar](50) NOT NULL,
	[MAP_Value] [varchar](1000) NOT NULL,
	[MAP_Module] [varchar](100) NULL
) ON [PRIMARY]
GO
