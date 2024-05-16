USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bando_LineaIntervento]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bando_LineaIntervento](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Linea] [nvarchar](50) NULL,
	[TipoIntervento] [nvarchar](250) NULL,
	[DocumentoIstanza] [varchar](50) NULL,
	[Importo] [float] NULL,
	[FormulaValutazione] [varchar](500) NULL
) ON [PRIMARY]
GO
