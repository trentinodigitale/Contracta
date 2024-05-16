USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Models]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Models](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[MOD_ID] [varchar](500) NULL,
	[MOD_Name] [varchar](500) NULL,
	[MOD_DescML] [varchar](500) NULL,
	[MOD_Type] [tinyint] NOT NULL,
	[MOD_Sys] [bit] NULL,
	[MOD_help] [text] NULL,
	[MOD_Param] [varchar](1000) NULL,
	[MOD_Module] [varchar](100) NULL,
	[MOD_Template] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
