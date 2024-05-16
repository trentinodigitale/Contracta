USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FAST_DPCM_DOCUMENTI_PUBBLICI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FAST_DPCM_DOCUMENTI_PUBBLICI](
	[IdMsg] [int] NOT NULL,
	[IdDoc] [varchar](1) NOT NULL,
	[msgIType] [int] NOT NULL,
	[msgISubType] [int] NOT NULL,
	[OPEN_DOC_NAME] [varchar](50) NULL,
	[IdMittente] [bigint] NULL,
	[TipoAppalto] [int] NOT NULL,
	[bScaduto] [int] NOT NULL,
	[bConcluso] [int] NOT NULL,
	[EvidenzaPubblica] [varchar](1) NOT NULL,
	[CriterioAggiudicazione] [int] NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[tipoprocedura] [varchar](20) NULL,
	[StatoGD] [varchar](1) NOT NULL,
	[Oggetto] [nvarchar](4000) NULL,
	[Tipo] [varchar](6) NOT NULL,
	[Contratto] [varchar](9) NOT NULL,
	[DenominazioneEnte] [nvarchar](1000) NULL,
	[SenzaImporto] [varchar](2) NOT NULL,
	[a_base_asta] [varchar](30) NULL,
	[a_base_asta_tec] [float] NULL,
	[di_aggiudicazione] [varchar](100) NULL,
	[DtPubblicazione] [varchar](4000) NULL,
	[RECEIVEDDATAMSG] [varchar](19) NULL,
	[DataInvio] [varchar](19) NULL,
	[DtScadenzaBando] [varchar](4000) NULL,
	[DtScadenzaBandoTecnical] [varchar](50) NULL,
	[DtScadenzaPubblEsito] [varchar](10) NULL,
	[RequisitiQualificazione] [varchar](1) NOT NULL,
	[CPV] [varchar](1) NOT NULL,
	[SCP] [varchar](50) NULL,
	[URL] [varchar](300) NULL,
	[CIG] [varchar](50) NULL,
	[RichiestaQuesito] [varchar](3) NOT NULL,
	[bEsito] [int] NOT NULL,
	[VisualizzaQuesiti] [varchar](50) NULL,
	[direzioneespletante] [varchar](1) NOT NULL,
	[Appalto_Verde] [varchar](10) NOT NULL,
	[Acquisto_Sociale] [varchar](10) NOT NULL,
	[DtPubblicazioneTecnical] [varchar](50) NULL,
	[Provincia] [nvarchar](80) NULL,
	[Comune] [nvarchar](80) NULL,
	[aziIndirizzoLeg] [nvarchar](80) NULL,
	[TipoEnte] [nvarchar](450) NULL,
	[Bando_Verde_Sociale] [varchar](205) NULL,
	[statoFunzionale] [varchar](50) NULL,
	[tipoDocOriginal] [varchar](50) NULL,
	[ambito] [varchar](255) NOT NULL,
	[titoloDocumento] [nvarchar](500) NULL,
	[DataChiusuraTecnical] [varchar](50) NULL,
	[Fascicolo] [varchar](50) NULL,
	[dataCreazione] [datetime] NULL,
	[EnteProponente] [nvarchar](max) NULL,
	[CodEnteProponente] [nvarchar](max) NULL,
	[Gestore] [int] NOT NULL,
	[RegistroSistema] [varchar](50) NULL,
	[Merceologia] [nvarchar](50) NULL,
	[JUMPCHECK] [nvarchar](255) NULL,
	[dataUltimaModifica] [varchar](19) NULL,
	[origineDati] [varchar](11) NOT NULL,
	[paginaJoomla] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
