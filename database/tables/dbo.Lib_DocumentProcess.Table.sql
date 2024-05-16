USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Lib_DocumentProcess]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lib_DocumentProcess](
	[DPR_idRow] [int] IDENTITY(1,1) NOT NULL,
	[DPR_DOC_ID] [nvarchar](50) NOT NULL,
	[DPR_ID] [nvarchar](50) NOT NULL,
	[DPR_ProgID] [nvarchar](250) NOT NULL,
	[DPR_DescrStep] [nvarchar](250) NOT NULL,
	[DPR_Order] [tinyint] NOT NULL,
	[DPR_Param] [ntext] NULL,
	[DPR_Module] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
