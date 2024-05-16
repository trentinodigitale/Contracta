USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_SIMOG_LOTTI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_SIMOG_LOTTI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NumeroLotto] [varchar](10) NULL,
	[OGGETTO] [nvarchar](max) NULL,
	[SOMMA_URGENZA] [varchar](10) NULL,
	[IMPORTO_LOTTO] [decimal](18, 2) NULL,
	[IMPORTO_SA] [decimal](18, 2) NULL,
	[IMPORTO_IMPRESA] [decimal](18, 2) NULL,
	[CPV] [varchar](20) NULL,
	[ID_SCELTA_CONTRAENTE] [varchar](20) NULL,
	[ID_CATEGORIA_PREVALENTE] [varchar](20) NULL,
	[TIPO_CONTRATTO] [varchar](20) NULL,
	[FLAG_ESCLUSO] [varchar](10) NULL,
	[LUOGO_ISTAT] [varchar](500) NULL,
	[IMPORTO_ATTUAZIONE_SICUREZZA] [decimal](18, 2) NULL,
	[FLAG_PREVEDE_RIP] [varchar](10) NULL,
	[FLAG_RIPETIZIONE] [varchar](10) NULL,
	[FLAG_CUP] [varchar](10) NULL,
	[CATEGORIA_SIMOG] [varchar](max) NULL,
	[EsitoControlli] [nvarchar](max) NULL,
	[StatoRichiestaLOTTO] [varchar](20) NULL,
	[CIG] [varchar](10) NULL,
	[note_canc] [nvarchar](1000) NULL,
	[MOTIVO_CANCELLAZIONE_LOTTO] [varchar](20) NULL,
	[AzioneProposta] [varchar](20) NULL,
	[MODALITA_ACQUISIZIONE] [varchar](20) NULL,
	[TIPOLOGIA_LAVORO] [varchar](20) NULL,
	[ID_ESCLUSIONE] [varchar](5) NULL,
	[Condizioni] [varchar](4000) NULL,
	[ID_AFF_RISERVATI] [varchar](10) NULL,
	[FLAG_REGIME] [varchar](10) NULL,
	[ART_REGIME] [varchar](10) NULL,
	[FLAG_DL50] [varchar](10) NULL,
	[PRIMA_ANNUALITA] [varchar](10) NULL,
	[ANNUALE_CUI_MININF] [varchar](100) NULL,
	[ID_MOTIVO_COLL_CIG] [varchar](3) NULL,
	[CIG_ORIGINE_RIP] [varchar](20) NULL,
	[IMPORTO_OPZIONI] [decimal](18, 2) NULL,
	[NotEditable] [varchar](4000) NULL,
	[SYNC_LUOGO_NUTS] [varchar](100) NULL,
	[SYNC_LUOGO_ISTAT] [varchar](100) NULL,
	[DURATA_ACCQUADRO_CONVENZIONE] [int] NULL,
	[DURATA_RINNOVI] [int] NULL,
	[CUP] [varchar](max) NULL,
	[FLAG_PNRR_PNC] [varchar](10) NULL,
	[ID_MOTIVO_DEROGA] [varchar](10) NULL,
	[FLAG_MISURE_PREMIALI] [varchar](10) NULL,
	[ID_MISURA_PREMIALE] [varchar](10) NULL,
	[FLAG_PREVISIONE_QUOTA] [varchar](10) NULL,
	[QUOTA_FEMMINILE] [varchar](10) NULL,
	[QUOTA_GIOVANILE] [varchar](10) NULL,
	[FLAG_USO_METODI_EDILIZIA] [varchar](10) NULL,
	[FLAG_DEROGA_ADESIONE] [varchar](10) NULL,
	[DEROGA_QUALIFICAZIONE_SA] [varchar](10) NULL,
	[idLottoEsterno] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_SIMOG_LOTTI] ADD  CONSTRAINT [DF_Document_SIMOG_LOTTI_IMPORTO_SA]  DEFAULT ((0)) FOR [IMPORTO_SA]
GO
ALTER TABLE [dbo].[Document_SIMOG_LOTTI] ADD  CONSTRAINT [DF_Document_SIMOG_LOTTI_IMPORTO_IMPRESA]  DEFAULT ((0)) FOR [IMPORTO_IMPRESA]
GO
