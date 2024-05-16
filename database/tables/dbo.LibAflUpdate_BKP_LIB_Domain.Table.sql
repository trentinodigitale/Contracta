USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LibAflUpdate_BKP_LIB_Domain]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LibAflUpdate_BKP_LIB_Domain](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DM_ID] [varchar](100) NULL,
	[DM_DescML] [varchar](255) NULL,
	[DM_Sys] [bit] NOT NULL,
	[DM_Query] [text] NULL,
	[DM_ConnectionString] [varchar](500) NULL,
	[DM_DynamicReload] [nvarchar](50) NULL,
	[DM_Module] [varchar](100) NULL,
	[DM_LastUpdate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
