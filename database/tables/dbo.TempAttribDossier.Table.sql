USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempAttribDossier]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempAttribDossier](
	[idPfu] [int] NOT NULL,
	[DZT_Name] [varchar](50) NULL,
	[TipoMem] [tinyint] NULL,
	[IdApp] [int] NULL,
	[Griglia] [int] NULL,
	[Filtro] [int] NULL,
	[Valore] [nvarchar](max) NULL,
	[Condizione] [varchar](20) NULL,
	[TableName] [varchar](60) NULL,
	[MA_Order] [smallint] NULL,
	[IdDzt] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
