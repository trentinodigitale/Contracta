USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ARTICOLI_DESCRIZIONI_LINGUA]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ARTICOLI_DESCRIZIONI_LINGUA](
	[ADL_Id] [int] IDENTITY(1,1) NOT NULL,
	[ADL_IdAzi] [int] NOT NULL,
	[ADL_CodArt] [varchar](50) NOT NULL,
	[ADL_Desc_I] [ntext] NOT NULL,
	[ADL_Desc_UK] [ntext] NOT NULL,
	[ADL_Desc_FRA] [ntext] NOT NULL,
	[ADL_Desc_E] [ntext] NOT NULL,
	[ADL_Desc_CN] [ntext] NOT NULL,
	[ADL_Desc_DE] [ntext] NOT NULL,
	[ADL_DataIns] [datetime] NOT NULL,
	[ADL_Desc_POL] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
