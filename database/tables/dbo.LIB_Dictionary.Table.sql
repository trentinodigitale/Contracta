USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LIB_Dictionary]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LIB_Dictionary](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DZT_Name] [varchar](50) NULL,
	[DZT_Type] [int] NULL,
	[DZT_DM_ID] [varchar](100) NULL,
	[DZT_DM_ID_Um] [int] NULL,
	[DZT_MultiValue] [int] NULL,
	[DZT_Len] [int] NULL,
	[DZT_Dec] [int] NULL,
	[DZT_DescML] [varchar](255) NULL,
	[DZT_Format] [varchar](500) NULL,
	[DZT_Sys] [bit] NOT NULL,
	[DZT_ValueDef] [varchar](8000) NULL,
	[DZT_Module] [varchar](100) NULL,
	[DZT_Help] [varchar](8000) NULL,
	[DZT_RegExp] [varchar](8000) NULL
) ON [PRIMARY]
GO
