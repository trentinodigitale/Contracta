USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Parametri_Abilitazioni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Parametri_Abilitazioni](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NOT NULL,
	[deleted] [int] NULL,
	[NumMesiScadenza] [int] NULL,
	[Sollecito] [int] NULL,
	[NumPeriodiFreqPrimaria] [int] NULL,
	[FreqPrimaria] [int] NULL,
	[FreqSecondaria] [int] NULL,
	[NumMaxPerConferma] [int] NULL,
	[TipoDoc] [varchar](100) NULL,
	[Note] [ntext] NULL,
	[TestoAmmessa] [ntext] NULL,
	[TestoRigetto] [ntext] NULL,
	[TestoIntegrativa] [ntext] NULL,
	[OggettoAmmessa] [nvarchar](max) NULL,
	[OggettoIntegrativa] [nvarchar](max) NULL,
	[OggettoRigetto] [nvarchar](max) NULL,
	[Attiva_Sospensione] [int] NULL,
	[N_DocInSeduta] [int] NULL,
	[Attiva_Mail_Riferimenti_conf_automatica] [int] NULL,
	[FreqControlli] [int] NULL,
	[Tipo_Estrazione] [int] NULL,
	[Perc_Soggetti] [float] NULL,
	[Num_estrazione_mista] [int] NULL,
	[elenco_documenti_controlli_OE] [nvarchar](max) NULL,
	[Conferma_Gestore] [int] NULL,
	[Attiva_vincolo_firma_digitale_sedute_valutazione] [varchar](50) NULL,
	[Scelta_Classi_Libera] [varchar](10) NULL,
	[Sospendi_Su_NuovaIstanza] [int] NULL,
	[TestoRigettoAutomatico] [ntext] NULL,
	[OggettoRigettoAutomatico] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Parametri_Abilitazioni] ADD  CONSTRAINT [DF_Document_Parametri_Abilitazioni_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[Document_Parametri_Abilitazioni] ADD  DEFAULT ('') FOR [Scelta_Classi_Libera]
GO
