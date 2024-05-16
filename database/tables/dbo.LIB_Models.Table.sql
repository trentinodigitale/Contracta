USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LIB_Models]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LIB_Models](
	[MOD_ID] [varchar](100) NOT NULL,
	[MOD_Name] [varchar](100) NOT NULL,
	[MOD_DescML] [varchar](500) NULL,
	[MOD_Type] [tinyint] NOT NULL,
	[MOD_Sys] [bit] NULL,
	[MOD_help] [text] NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[MOD_Param] [varchar](1000) NULL,
	[MOD_Module] [varchar](100) NULL,
	[MOD_Template] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
