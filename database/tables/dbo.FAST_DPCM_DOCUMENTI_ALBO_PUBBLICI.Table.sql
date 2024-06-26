USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FAST_DPCM_DOCUMENTI_ALBO_PUBBLICI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FAST_DPCM_DOCUMENTI_ALBO_PUBBLICI](
	[IdMsg] [int] NOT NULL,
	[IdPfu] [bigint] NULL,
	[msgIType] [int] NOT NULL,
	[msgIsubType] [int] NOT NULL,
	[Name] [nvarchar](500) NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[ProtocolloOfferta] [varchar](50) NULL,
	[ReceidevDataMsg] [datetime] NULL,
	[Oggetto] [nvarchar](4000) NULL,
	[Tipologia] [varchar](1) NOT NULL,
	[ExpiryDate] [datetime] NULL,
	[ImportoBaseAsta] [varchar](1) NOT NULL,
	[tipoprocedura] [varchar](1) NOT NULL,
	[StatoGd] [varchar](1) NOT NULL,
	[Fascicolo] [varchar](50) NULL,
	[CriterioAggiudicazione] [varchar](1) NOT NULL,
	[CriterioFormulazioneOfferta] [varchar](1) NOT NULL,
	[DOCUMENT] [varchar](5) NOT NULL,
	[IDDOCR] [int] NOT NULL,
	[Precisazioni] [int] NOT NULL,
	[DtPubblicazione] [varchar](4000) NULL,
	[DtPubblicazioneTecnical] [varchar](50) NULL,
	[JumpCheck] [nvarchar](255) NOT NULL,
	[StatoFunzionale] [varchar](50) NULL,
	[DtScadenzaBandoTecnical] [varchar](50) NULL,
	[DenominazioneEnte] [nvarchar](1000) NULL,
	[Gestore] [int] NOT NULL,
	[RegistroSistema] [varchar](50) NULL,
	[origineDati] [varchar](11) NOT NULL,
	[paginaJoomla] [varchar](500) NULL,
	[RECEIVEDDATAMSG] [varchar](1) NOT NULL
) ON [PRIMARY]
GO
