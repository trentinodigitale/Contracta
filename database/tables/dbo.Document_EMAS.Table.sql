USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_EMAS]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_EMAS](
	[IdQuest] [int] IDENTITY(1,1) NOT NULL,
	[StatoQuest] [varchar](50) NULL,
	[Owner] [int] NULL,
	[IdAzienda] [int] NULL,
	[Protocollo] [varchar](50) NULL,
	[DataCompilazione] [datetime] NULL,
	[AttivitaEsercitata] [nvarchar](500) NULL,
	[OrganicoMedio] [int] NULL,
	[VolumeAffari] [float] NULL,
	[Ecogestione] [varchar](20) NULL,
	[IscrizioneEco] [varchar](100) NULL,
	[ProssimaIscrEco] [varchar](20) NULL,
	[DataProssimaIscrEco] [datetime] NULL,
	[CertificazioneAmbientale] [varchar](20) NULL,
	[RifCertAmbientale] [varchar](50) NULL,
	[ProssimaIscrAmbientale] [varchar](20) NULL,
	[DataProssimaCertAmb] [datetime] NULL,
	[Certificazioni] [varchar](20) NULL,
	[AltreCertificazioni] [varchar](500) NULL,
	[ProcedureInterne] [varchar](20) NULL,
	[DescrProcedureInterne] [varchar](500) NULL,
	[Formazione] [varchar](20) NULL,
	[ResponsabileAmbiente] [varchar](20) NULL,
	[NomeResponsabile] [varchar](100) NULL,
	[RuoloResponsabile] [varchar](100) NULL,
	[SelezioniFornitori] [varchar](20) NULL,
	[Note] [nvarchar](4000) NULL,
	[Allegato] [varchar](255) NULL,
	[Deleted] [char](1) NULL,
	[DichiarazionePolAmb] [varchar](1) NULL,
	[NomeComp] [varchar](50) NULL,
	[PosizioneAz] [varchar](50) NULL,
	[Id_From] [int] NULL,
	[CertOHSAS] [varchar](5) NULL,
	[NroOHSAS] [varchar](50) NULL,
	[ProssimaIscrOHSAS] [varchar](5) NULL,
	[DataProssimaIscrOHSAS] [datetime] NULL,
	[ProcScarichiIdrici] [varchar](5) NULL,
	[ProcEmissioniAtmosfera] [varchar](5) NULL,
	[ProcRifiuti] [varchar](5) NULL,
	[ProcConsumoRisorse] [varchar](5) NULL,
	[ProcSostanzePericolose] [varchar](5) NULL,
	[ProcRumore] [varchar](5) NULL,
	[ProcEmergenze] [varchar](5) NULL,
	[ConsumiEnergetici] [varchar](5) NULL,
	[EmissioniControllate] [varchar](5) NULL,
	[EmissioniIncontrollate] [varchar](5) NULL,
	[ScarichiControllati] [varchar](5) NULL,
	[ScarichiIncontrollati] [varchar](5) NULL,
	[UsoRisorseNaturali] [varchar](5) NULL,
	[UsoSostanzePericolosi] [varchar](5) NULL,
	[RifiutiNonPericolosi] [varchar](5) NULL,
	[RifiutiPericolosi] [varchar](5) NULL,
	[UsoTerreno] [varchar](5) NULL,
	[RischioIncidentiAmb] [varchar](5) NULL,
	[Biodiversita] [varchar](5) NULL,
	[QuestioniLocali] [varchar](5) NULL,
	[QuestioniTrasporti] [varchar](5) NULL,
	[AspettiIndiretti] [varchar](5) NULL,
	[mailcompilatore] [varchar](255) NULL,
 CONSTRAINT [PK_Document_EMAS] PRIMARY KEY CLUSTERED 
(
	[IdQuest] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 97, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_EMAS] ADD  CONSTRAINT [DF_Document_EMAS_StatoQuest]  DEFAULT ('Saved') FOR [StatoQuest]
GO
ALTER TABLE [dbo].[Document_EMAS] ADD  CONSTRAINT [DF_Document_EMAS_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
