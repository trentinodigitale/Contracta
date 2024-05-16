USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[RagSoc] [varchar](300) NULL,
	[PIVA] [varchar](300) NULL,
	[INDIRIZZOLEG] [varchar](300) NULL,
	[LOCALITALEG] [varchar](300) NULL,
	[PROVINCIALEG] [varchar](300) NULL,
	[aziStatoLeg] [varchar](300) NULL,
	[aziCapLeg] [varchar](300) NULL,
	[QualificazioneAzi] [varchar](300) NULL,
	[BilancioCertificato] [varchar](300) NULL,
	[PoliticaAmbientale] [varchar](300) NULL,
	[CertificazioniAzi] [varchar](300) NULL,
	[Numerodipendenti] [varchar](300) NULL,
	[NrFornitori] [float] NULL,
	[Ordinato] [float] NULL,
	[FatturatoFornitore] [float] NULL,
	[Debiti] [float] NULL,
	[CapitaleNetto] [float] NULL,
	[RedditoOperativo] [float] NULL,
	[INDIRIZZOOp] [varchar](300) NULL,
	[LOCALITAOp] [varchar](300) NULL,
	[PROVINCIAOp] [varchar](300) NULL,
	[aziStatoOp] [varchar](300) NULL,
	[aziCapOp] [varchar](300) NULL,
	[AreaValutazione] [varchar](100) NULL,
	[Punteggio] [float] NULL,
	[IsTestata] [int] NULL,
	[RisultatoNetto] [float] NULL,
	[CapitaleInvestito] [float] NULL,
	[PatrimonioNetto] [float] NULL,
	[FatturatoNettoAnnoN] [float] NULL,
	[FatturatoNettoAnnoN_2] [float] NULL,
	[FatturatoNettoAnnoN_1] [float] NULL,
	[VolumeInvestimentiAnnoN] [float] NULL,
	[VolumeInvestimentiAnnoN_1] [float] NULL,
	[VolumeInvestimentiAnnoN_2] [float] NULL,
	[Merceologia] [varchar](5000) NULL,
	[MerceologiaBando] [varchar](5000) NULL
) ON [PRIMARY]
GO
