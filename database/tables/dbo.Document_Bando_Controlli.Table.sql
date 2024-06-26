USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bando_Controlli]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bando_Controlli](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [nchar](10) NULL,
	[IdControlli] [int] NULL,
	[Sezione] [varchar](20) NULL,
	[TipoControllo] [varchar](20) NULL,
	[Auto_Manuale] [varchar](20) NULL,
	[CriterioTec] [ntext] NULL,
	[CriterioDesc] [ntext] NULL,
	[RangeDa] [float] NULL,
	[RangeA] [float] NULL,
	[NumDec] [int] NULL,
	[TipoCampo] [int] NULL,
	[Sort] [int] NULL,
	[Sanabile] [int] NULL,
	[TipoInterventoControllo] [varchar](50) NULL,
	[LineaControllo] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Bando_Controlli] ADD  DEFAULT (0) FOR [Sanabile]
GO
