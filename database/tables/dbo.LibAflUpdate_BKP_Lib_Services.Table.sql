USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LibAflUpdate_BKP_Lib_Services]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LibAflUpdate_BKP_Lib_Services](
	[SRV_id] [int] IDENTITY(1,1) NOT NULL,
	[SRV_Description] [text] NULL,
	[SRV_DOC_ID] [nvarchar](50) NULL,
	[SRV_DPR_ID] [nvarchar](50) NULL,
	[SRV_SecInterval] [int] NULL,
	[SRV_SQL] [text] NULL,
	[SRV_LastExec] [datetime] NULL,
	[SRV_Module] [varchar](100) NULL,
	[bDeleted] [int] NOT NULL,
	[SRV_KEY] [nvarchar](500) NULL,
	[SRV_PARAM] [nvarchar](max) NULL,
	[SRV_SOGLIA] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
