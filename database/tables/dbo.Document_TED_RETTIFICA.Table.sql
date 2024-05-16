USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_TED_RETTIFICA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_TED_RETTIFICA](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[SECTION_NUMBER] [varchar](10) NOT NULL,
	[SECTION_TO_MODIFY] [varchar](400) NULL,
	[OLD_VALUE_TEXT] [nvarchar](max) NULL,
	[NEW_VALUE_TEXT] [nvarchar](max) NULL,
	[OLD_VALUE_DATE] [varchar](50) NULL,
	[NEW_VALUE_DATE] [varchar](50) NULL,
	[OLD_VALUE_TIME] [varchar](5) NULL,
	[NEW_VALUE_TIME] [varchar](5) NULL,
	[TED_RETTIFICA_SEZIONE] [nvarchar](max) NULL,
	[TED_RETTIFICA_VAL_OLD] [nvarchar](max) NULL,
	[TED_RETTIFICA_VAL_NEW] [nvarchar](max) NULL,
	[OLD_MAIN_CPV_SEC] [varchar](50) NULL,
	[NEW_MAIN_CPV_SEC] [varchar](50) NULL,
	[CIG_RETTIFICA] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
