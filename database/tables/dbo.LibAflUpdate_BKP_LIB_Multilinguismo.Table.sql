USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LibAflUpdate_BKP_LIB_Multilinguismo]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LibAflUpdate_BKP_LIB_Multilinguismo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ML_KEY] [varchar](255) NOT NULL,
	[ML_LNG] [varchar](5) NOT NULL,
	[ML_Description] [ntext] NOT NULL,
	[ML_Context] [int] NOT NULL,
	[ML_Module] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
