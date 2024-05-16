USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[ID] [int] NULL,
	[DOC_Owner] [varchar](20) NULL,
	[DOC_Name] [nvarchar](500) NULL,
	[DataCreazione] [datetime] NULL,
	[Protocol] [nvarchar](50) NULL,
	[DescrizioneEstesa] [ntext] NULL,
	[StatoConvenzione] [nvarchar](20) NULL,
	[AZI] [nvarchar](10) NULL,
	[Plant] [nvarchar](50) NULL,
	[Deleted] [int] NULL,
	[AZI_Dest] [nvarchar](10) NULL,
	[NumOrd] [nvarchar](50) NULL,
	[Imballo] [nvarchar](10) NULL,
	[Resa] [nvarchar](10) NULL,
	[Spedizione] [nvarchar](10) NULL,
	[Pagamento] [nvarchar](10) NULL,
	[Valuta] [nvarchar](10) NULL,
	[Total] [float] NULL,
	[Completo] [nvarchar](20) NULL,
	[Allegato] [nvarchar](250) NULL,
	[Telefono] [nvarchar](50) NULL,
	[Compilatore] [nvarchar](50) NULL,
	[RuoloCompilatore] [nvarchar](50) NULL,
	[TipoOrdine] [nchar](1) NULL,
	[SendingDate] [datetime] NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[DataInizio] [datetime] NULL,
	[DataFine] [datetime] NULL,
	[Merceologia] [nvarchar](50) NULL,
	[TotaleOrdinato] [float] NULL,
	[IVA] [int] NULL,
	[NewTotal] [float] NULL,
	[RicPropBozza] [varchar](10) NOT NULL,
	[ConvNoMail] [char](1) NULL,
	[QtMinTot] [float] NULL,
	[RicPreventivo] [varchar](10) NULL,
	[TipoImporto] [varchar](50) NULL,
	[TipoEstensione] [varchar](50) NULL,
	[RichiediFirmaOrdine] [char](1) NULL,
	[StatoContratto] [varchar](20) NULL,
	[StatoListino] [varchar](20) NULL,
	[OggettoBando] [ntext] NULL,
	[DataProtocolloBando] [datetime] NULL,
	[Mandataria] [nvarchar](10) NULL,
	[ProtocolloContratto] [varchar](50) NULL,
	[ProtocolloListino] [varchar](50) NULL,
	[DataContratto] [datetime] NULL,
	[DataListino] [datetime] NULL,
	[ReferenteFornitore] [nvarchar](20) NULL,
	[CodiceFiscaleReferente] [nvarchar](50) NULL,
	[ReferenteFornitoreHide] [nvarchar](50) NULL,
	[Ambito] [nvarchar](50) NULL,
	[NotEditable] [nvarchar](2000) NULL,
	[GestioneQuote] [varchar](100) NULL,
	[IdentificativoIniziativa] [varchar](50) NULL,
	[DescrizioneIniziativa] [ntext] NULL,
	[DataStipulaConvenzione] [datetime] NULL,
	[RichiestaFirma] [nvarchar](10) NULL,
	[CIG_MADRE] [nvarchar](50) NULL,
	[TipoConvenzione] [varchar](50) NULL,
	[ConAccessori] [varchar](10) NULL,
	[ImportoMinimoOrdinativo] [float] NULL,
	[OrdinativiIntegrativi] [char](1) NULL,
	[TipoScadenzaOrdinativo] [varchar](150) NULL,
	[NumeroMesi] [int] NULL,
	[DataScadenzaOrdinativo] [datetime] NULL,
	[Macro_Convenzione] [nvarchar](500) NULL,
	[idBando] [int] NULL,
	[EvidenzaPubblica] [int] NULL,
	[Stipula_in_forma_pubblica] [int] NULL,
	[DataSollecito] [datetime] NULL,
	[PossibilitaRinnovo] [varchar](10) NULL,
	[DataDirittoOblio] [datetime] NULL,
	[UserRUP] [int] NULL,
	[ConvenzioniInUrgenza] [char](1) NULL,
	[AllegatoDetermina] [nvarchar](1000) NULL,
	[FondiFinanziamento] [varchar](50) NULL,
	[DPCM] [varchar](20) NULL,
	[PresenzaListinoOrdini] [varchar](10) NULL,
	[ProtocolloListinoOrdini] [varchar](50) NULL,
	[DataListinoOrdini] [datetime] NULL,
	[StatoListinoOrdini] [varchar](50) NULL,
	[TotalOrigine] [float] NULL,
	[GenderEquality] [varchar](10) NULL,
	[DirettoreEsecuzioneContratto] [varchar](50) NULL,
	[Importo_Cauzione] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  CONSTRAINT [DF__Document___Stato__08F67376]  DEFAULT ('Saved') FOR [StatoConvenzione]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  CONSTRAINT [DF__Document___Delet__09EA97AF]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  CONSTRAINT [DF__Document___TipoO__0ADEBBE8]  DEFAULT ('c') FOR [TipoOrdine]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  CONSTRAINT [DF_Document_Convenzione_TotaleOrdinato]  DEFAULT ((0)) FOR [TotaleOrdinato]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  CONSTRAINT [DF_Document_Convenzione_RicPropBozza]  DEFAULT ((0)) FOR [RicPropBozza]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  CONSTRAINT [DF_Document_Convenzione_RicPreventivo]  DEFAULT ('0') FOR [RicPreventivo]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  CONSTRAINT [DF_Document_Convenzione_RichiediFirmaOrdine]  DEFAULT ('') FOR [RichiediFirmaOrdine]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  DEFAULT ('0') FOR [OrdinativiIntegrativi]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  DEFAULT ((0)) FOR [idBando]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  DEFAULT ('') FOR [PossibilitaRinnovo]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  DEFAULT ('0') FOR [ConvenzioniInUrgenza]
GO
ALTER TABLE [dbo].[Document_Convenzione] ADD  DEFAULT ('') FOR [PresenzaListinoOrdini]
GO
