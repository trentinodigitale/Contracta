USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_ModelAttributes]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_ModelAttributes](
	[MA_ID] [int] IDENTITY(1,1) NOT NULL,
	[MA_MOD_ID] [varchar](500) NULL,
	[MA_DZT_Name] [varchar](100) NULL,
	[MA_DescML] [varchar](500) NULL,
	[MA_Pos] [smallint] NULL,
	[MA_Len] [smallint] NOT NULL,
	[MA_Order] [smallint] NOT NULL,
	[DZT_Type] [int] NULL,
	[DZT_DM_ID] [varchar](20) NULL,
	[DZT_DM_ID_Um] [int] NULL,
	[DZT_Len] [int] NULL,
	[DZT_Dec] [int] NULL,
	[DZT_Format] [varchar](50) NULL,
	[DZT_Help] [varchar](1000) NULL,
	[DZT_Multivalue] [int] NULL,
	[MA_Module] [varchar](100) NULL
) ON [PRIMARY]
GO
