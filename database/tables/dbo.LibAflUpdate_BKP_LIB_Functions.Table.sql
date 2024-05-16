USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LibAflUpdate_BKP_LIB_Functions]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LibAflUpdate_BKP_LIB_Functions](
	[LFN_id] [nvarchar](50) NOT NULL,
	[LFN_Context] [int] NOT NULL,
	[LFN_GroupFunction] [varchar](500) NULL,
	[LFN_PosPermission] [int] NULL,
	[LFN_CaptionML] [varchar](255) NULL,
	[LFN_TooltipML] [varchar](255) NULL,
	[LFN_UrlImage] [varchar](255) NULL,
	[LFN_UrlNewPage] [varchar](1000) NULL,
	[LFN_Target] [varchar](255) NULL,
	[LFN_paramTarget] [varchar](4000) NULL,
	[LFN_OnClick] [varchar](255) NULL,
	[LFN_Order] [int] NOT NULL,
	[LFN_Condition] [varchar](800) NULL,
	[LFN_Module] [varchar](100) NULL,
	[LFN_Identity] [int] IDENTITY(1,1) NOT NULL,
	[LFN_UrlImageBackup] [varchar](500) NULL,
	[LFN_AccessKey] [varchar](2) NULL
) ON [PRIMARY]
GO
