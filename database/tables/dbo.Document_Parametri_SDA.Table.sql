USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Parametri_SDA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Parametri_SDA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NOT NULL,
	[deleted] [int] NULL,
	[DataInizio] [datetime] NULL,
	[DataFine] [datetime] NULL,
	[NumAnniApertura] [int] NULL,
	[NumGiorniValutazione] [int] NULL,
	[NumGiorniPresentazioneDomande] [int] NULL,
	[PresenzaBustaTecnica] [int] NULL,
	[PeriodoValiditaAmmissione] [int] NULL,
	[SollecitoRinnovo] [int] NULL,
	[NotificaRettificaSDA] [int] NULL,
	[NotificaRettificaSemplificato] [int] NULL,
	[NumeroMancateRisposte] [int] NULL,
	[SospensionePropostaRevoca] [int] NULL,
	[SospensioneAmmissioneSDA] [int] NULL,
	[InvitiSemplificatoCoerenti] [varchar](20) NULL,
	[NumGiorniDomandaPartecipazione] [int] NULL,
	[Obbligo_valutazione_istanze] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Parametri_SDA] ADD  CONSTRAINT [DF_Document_Parametri_SDA_deleted]  DEFAULT (0) FOR [deleted]
GO
ALTER TABLE [dbo].[Document_Parametri_SDA] ADD  CONSTRAINT [DF_Document_Parametri_SDA_DataInizio]  DEFAULT (getdate()) FOR [DataInizio]
GO
ALTER TABLE [dbo].[Document_Parametri_SDA] ADD  CONSTRAINT [DF_Document_Parametri_SDA_SollecitoRinnovo]  DEFAULT (0) FOR [SollecitoRinnovo]
GO
ALTER TABLE [dbo].[Document_Parametri_SDA] ADD  DEFAULT ('') FOR [InvitiSemplificatoCoerenti]
GO
