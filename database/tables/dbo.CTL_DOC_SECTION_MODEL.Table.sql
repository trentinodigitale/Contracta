USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DOC_SECTION_MODEL]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DOC_SECTION_MODEL](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[DSE_ID] [varchar](500) NULL,
	[MOD_Name] [varchar](500) NULL
) ON [PRIMARY]
GO
