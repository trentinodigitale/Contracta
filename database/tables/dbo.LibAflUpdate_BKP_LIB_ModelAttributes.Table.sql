USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LibAflUpdate_BKP_LIB_ModelAttributes]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LibAflUpdate_BKP_LIB_ModelAttributes](
	[MA_ID] [int] IDENTITY(1,1) NOT NULL,
	[MA_MOD_ID] [varchar](100) NOT NULL,
	[MA_DZT_Name] [varchar](100) NULL,
	[MA_DescML] [varchar](255) NULL,
	[MA_Pos] [smallint] NULL,
	[MA_Len] [smallint] NOT NULL,
	[MA_Order] [smallint] NOT NULL,
	[MA_Module] [varchar](100) NULL
) ON [PRIMARY]
GO
