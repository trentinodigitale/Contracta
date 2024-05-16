USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FAST_DPCM_ULTIMI_DOCUMENTI_PUBBLICI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FAST_DPCM_ULTIMI_DOCUMENTI_PUBBLICI](
	[IdMsg] [int] NOT NULL,
	[OPEN_DOC_NAME] [varchar](101) NULL,
	[ProtocolloBando] [nvarchar](50) NULL,
	[Oggetto] [nvarchar](4000) NULL,
	[Tipo] [varchar](6) NOT NULL,
	[DtPubblicazione] [varchar](4000) NULL,
	[DtScadenzaBando] [varchar](4000) NULL,
	[DtScadenzaBandoTecnical] [varchar](50) NULL,
	[RichiestaQuesito] [varchar](3) NOT NULL,
	[VisualizzaQuesiti] [varchar](3) NOT NULL
) ON [PRIMARY]
GO
