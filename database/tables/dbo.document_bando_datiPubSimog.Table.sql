USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_bando_datiPubSimog]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_bando_datiPubSimog](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[simog_id_gara] [varchar](50) NULL,
	[indexCollaborazione] [int] NULL,
	[LINK_SITO] [nvarchar](max) NULL,
	[NUMERO_QUOTIDIANI_NAZ] [int] NULL,
	[NUMERO_QUOTIDIANI_REGIONALI] [int] NULL,
	[DATA_PUBBLICAZIONE] [varchar](100) NULL,
	[DATA_SCADENZA_PAG] [varchar](100) NULL,
	[ORA_SCADENZA] [varchar](10) NULL,
	[ID_SCELTA_CONTRAENTE] [varchar](20) NULL,
	[versioneSimog] [varchar](100) NULL,
	[HIDE_DATI_PUBBLICAZIONE] [int] NULL,
	[DATA_SCADENZA_RICHIESTA_INVITO] [varchar](100) NULL,
	[DATA_LETTERA_INVITO] [varchar](100) NULL,
	[fileBandoDiGara] [nvarchar](4000) NULL,
	[LINK_AFFIDAMENTO_DIRETTO] [nvarchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
