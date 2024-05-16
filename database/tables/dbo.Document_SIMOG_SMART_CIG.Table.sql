USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_SIMOG_SMART_CIG]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_SIMOG_SMART_CIG](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[indexCollaborazione] [int] NULL,
	[ID_STAZIONE_APPALTANTE] [varchar](100) NULL,
	[DENOM_STAZIONE_APPALTANTE] [nvarchar](max) NULL,
	[CF_AMMINISTRAZIONE] [varchar](20) NULL,
	[DENOM_AMMINISTRAZIONE] [nvarchar](max) NULL,
	[CF_UTENTE] [varchar](50) NULL,
	[IMPORTO_GARA] [decimal](18, 2) NULL,
	[codiceFattispecieContrattuale] [varchar](10) NULL,
	[codiceProceduraSceltaContraente] [varchar](10) NULL,
	[codiceClassificazioneGara] [varchar](10) NULL,
	[cigAccordoQuadro] [varchar](10) NULL,
	[cup] [varchar](20) NULL,
	[motivo_rich_cig_comuni] [varchar](10) NULL,
	[motivo_rich_cig_catmerc] [varchar](10) NULL,
	[CATEGORIE_MERC] [varchar](max) NULL,
	[smart_cig] [varchar](10) NULL,
	[idpfuRup] [int] NULL,
	[EsitoControlli] [nvarchar](max) NULL,
	[CIG_ACC_QUADRO] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
