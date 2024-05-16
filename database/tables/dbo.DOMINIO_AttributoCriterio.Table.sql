USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DOMINIO_AttributoCriterio]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DOMINIO_AttributoCriterio](
	[DMV_DM_ID] [int] NOT NULL,
	[DMV_Cod] [nvarchar](551) NULL,
	[DMV_Father] [varchar](1) NOT NULL,
	[DMV_Level] [int] NOT NULL,
	[DMV_DescML] [nvarchar](max) NULL,
	[DMV_Image] [varchar](1) NOT NULL,
	[DMV_Sort] [int] NOT NULL,
	[DMV_CodExt] [varchar](1) NOT NULL,
	[DZT_NAME] [varchar](50) NULL,
	[TipoBando] [nvarchar](510) NULL,
	[DZT_Type] [int] NULL,
	[Attributo] [varchar](50) NULL,
	[DZT_Format] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
