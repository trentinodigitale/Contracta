USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TAB_MESSAGGI_FIELDS]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TAB_MESSAGGI_FIELDS](
	[IdMsg] [int] NOT NULL,
	[iType] [varchar](50) NOT NULL,
	[iSubType] [varchar](50) NOT NULL,
	[IdDoc] [varchar](50) NOT NULL,
	[Stato] [varchar](50) NOT NULL,
	[AdvancedState] [char](2) NOT NULL,
	[PersistenceType] [char](1) NOT NULL,
	[IdMarketPlace] [char](1) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Protocol] [nvarchar](50) NOT NULL,
	[IdMittente] [varchar](50) NOT NULL,
	[IdDestinatario] [varchar](50) NOT NULL,
	[Read] [char](1) NOT NULL,
	[Data] [varchar](50) NOT NULL,
	[ReceivedDataMsg] [varchar](50) NOT NULL,
	[ExpiryDate] [varchar](50) NOT NULL,
	[ProtocolloBando] [nvarchar](50) NOT NULL,
	[Object] [nvarchar](4000) NOT NULL,
	[Object_Cover1] [nvarchar](4000) NOT NULL,
	[ProtocolloOfferta] [nvarchar](50) NOT NULL,
	[ProceduraGaraTradizionale] [varchar](50) NOT NULL,
	[tipoappalto] [varchar](50) NOT NULL,
	[CriterioAggiudicazioneGara] [varchar](50) NOT NULL,
	[AuctionState] [varchar](50) NOT NULL,
	[DataInizioAsta] [varchar](50) NOT NULL,
	[DataFineAsta] [varchar](50) NOT NULL,
	[ImportoBaseAsta] [varchar](50) NOT NULL,
	[ImportoAppalto] [varchar](50) NOT NULL,
	[ProceduraGara] [varchar](50) NOT NULL,
	[ProtocolBG] [nvarchar](50) NOT NULL,
	[AggiudicazioneGara] [varchar](50) NOT NULL,
	[CriterioFormulazioneOfferte] [varchar](50) NOT NULL,
	[NumProduct_BANDO_rettifiche] [varchar](50) NOT NULL,
	[RagSoc] [nvarchar](450) NULL,
	[ReceivedOff] [varchar](10) NULL,
	[ReceivedQuesiti] [varchar](10) NULL,
	[TipoProcedura] [varchar](10) NULL,
	[NameBG] [nvarchar](500) NULL,
	[TipoAsta] [varchar](10) NULL,
	[ReceivedDomanda] [varchar](10) NULL,
	[ReceivedIscrizioni] [varchar](10) NULL,
	[sysHabilitStartDate] [varchar](50) NULL,
	[CIG] [varchar](100) NULL,
	[FaseGara] [varchar](50) NULL,
	[DataAperturaOfferte] [varchar](50) NULL,
	[DataAperturaDomande] [varchar](50) NULL,
	[DataIISeduta] [varchar](50) NULL,
	[DataSedutaGara] [varchar](50) NULL,
	[TermineRichiestaQuesiti] [varchar](50) NULL,
	[VisualizzaNotifiche] [nvarchar](50) NULL,
	[TipoBando] [nvarchar](50) NULL,
	[EvidenzaPubblica] [varchar](10) NULL,
	[ModalitadiPartecipazione] [nvarchar](50) NULL,
	[IdAziendaAti] [nvarchar](50) NULL,
	[ECONOMICA_ENCRYPT] [varchar](10) NULL,
	[TECNICA_ENCRYPT] [varchar](10) NULL,
	[ProtocolloInformaticoUscita] [varchar](50) NULL,
	[DataProtocolloInformaticoUscita] [varchar](50) NULL,
	[ListaModelliMicrolotti] [varchar](100) NOT NULL,
	[ImportoBaseAsta2] [varchar](50) NULL,
	[DataPubblicazioneBando] [varchar](50) NULL,
	[ValoreOfferta] [varchar](50) NULL,
	[Rispondere_dal] [varchar](50) NULL,
	[RichiestaQuesito] [varchar](5) NULL,
	[CUP] [varchar](100) NULL,
	[DirezioneEspletante] [varchar](100) NULL,
	[DataPubblicazioneSulPortale] [varchar](50) NULL,
	[NumProduct_PRODUCTS3_rettifiche] [varchar](100) NULL,
	[Appalto_Verde] [varchar](50) NULL,
	[Acquisto_Sociale] [varchar](50) NULL,
	[Motivazione_Appalto_Verde] [ntext] NULL,
	[Motivazione_Acquisto_Sociale] [ntext] NULL,
	[ProceduraGara2] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_iType]  DEFAULT ('') FOR [iType]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_SubType]  DEFAULT ('-1') FOR [iSubType]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_IdDoc]  DEFAULT ('') FOR [IdDoc]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_Stato]  DEFAULT ('') FOR [Stato]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_AdvancedState]  DEFAULT ('') FOR [AdvancedState]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_PersistenceType]  DEFAULT ('') FOR [PersistenceType]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_IdMarketPlace]  DEFAULT ('') FOR [IdMarketPlace]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_Protocol]  DEFAULT ('') FOR [Protocol]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_IdMittente]  DEFAULT ('') FOR [IdMittente]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_IdDestinatario]  DEFAULT ('') FOR [IdDestinatario]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_Read]  DEFAULT ('') FOR [Read]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_Data]  DEFAULT ('') FOR [Data]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ReceivedDataMsg]  DEFAULT ('') FOR [ReceivedDataMsg]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ExpiryDate]  DEFAULT ('') FOR [ExpiryDate]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ProtocolloBando]  DEFAULT ('') FOR [ProtocolloBando]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_Object]  DEFAULT ('') FOR [Object]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_Object_Cover1]  DEFAULT ('') FOR [Object_Cover1]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ProtocolloOfferta]  DEFAULT ('') FOR [ProtocolloOfferta]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ProceduraGaraTradizionale]  DEFAULT ('') FOR [ProceduraGaraTradizionale]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_tipoappalto]  DEFAULT ('') FOR [tipoappalto]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_CriterioAggiudicazioneGara]  DEFAULT ('') FOR [CriterioAggiudicazioneGara]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_AuctionState]  DEFAULT ('') FOR [AuctionState]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DataInizioAsta]  DEFAULT ('') FOR [DataInizioAsta]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DataFineAsta]  DEFAULT ('') FOR [DataFineAsta]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ImportoBaseAsta]  DEFAULT ('') FOR [ImportoBaseAsta]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ImportoAppalto]  DEFAULT ('') FOR [ImportoAppalto]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ProceduraGara]  DEFAULT ('') FOR [ProceduraGara]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ProtocolBG]  DEFAULT ('') FOR [ProtocolBG]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_AggiudicazioneGara]  DEFAULT ('') FOR [AggiudicazioneGara]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_CriterioFormulazioneOfferte]  DEFAULT ('') FOR [CriterioFormulazioneOfferte]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_NumProduct_BANDO_rettifiche]  DEFAULT ('') FOR [NumProduct_BANDO_rettifiche]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_RagSoc]  DEFAULT ('') FOR [RagSoc]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ReceivedOff]  DEFAULT ('') FOR [ReceivedOff]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ReceivedQuesiti]  DEFAULT ('') FOR [ReceivedQuesiti]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_TipoProcedura]  DEFAULT ('') FOR [TipoProcedura]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_NameBG]  DEFAULT ('') FOR [NameBG]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_TipoAsta]  DEFAULT ('') FOR [TipoAsta]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ReceivedDomanda]  DEFAULT ('') FOR [ReceivedDomanda]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ReceivedIscrizioni]  DEFAULT ('') FOR [ReceivedIscrizioni]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_sysHabilitStartDate]  DEFAULT ('') FOR [sysHabilitStartDate]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_CIG]  DEFAULT ('') FOR [CIG]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_FaseGara]  DEFAULT ('') FOR [FaseGara]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DataAperturaOfferte]  DEFAULT ('') FOR [DataAperturaOfferte]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DataAperturaDomande]  DEFAULT ('') FOR [DataAperturaDomande]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DataIISeduta]  DEFAULT ('') FOR [DataIISeduta]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DataSedutaGara]  DEFAULT ('') FOR [DataSedutaGara]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_TermineRichiestaQuesiti]  DEFAULT ('') FOR [TermineRichiestaQuesiti]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_VisualizzaNotifiche]  DEFAULT ('') FOR [VisualizzaNotifiche]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_TipoBando]  DEFAULT ('') FOR [TipoBando]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_EvidenzaPubblica]  DEFAULT ('') FOR [EvidenzaPubblica]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ModalitadiPartecipazione]  DEFAULT ('') FOR [ModalitadiPartecipazione]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_IdAziendaAti]  DEFAULT ('') FOR [IdAziendaAti]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ECONOMICA_ENCRYPT]  DEFAULT ('') FOR [ECONOMICA_ENCRYPT]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_TECNICA_ENCRYPT]  DEFAULT ('') FOR [TECNICA_ENCRYPT]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ListaModelliMicrolotti]  DEFAULT ('') FOR [ListaModelliMicrolotti]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_ValoreOfferta]  DEFAULT ('') FOR [ValoreOfferta]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_RichiestaQuesito]  DEFAULT ('') FOR [RichiestaQuesito]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF__TAB_MESSAGG__CUP__6406469E]  DEFAULT ('') FOR [CUP]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DirezioneEspletante]  DEFAULT ('') FOR [DirezioneEspletante]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_DataPubblicazioneSulPortale]  DEFAULT ('') FOR [DataPubblicazioneSulPortale]
GO
ALTER TABLE [dbo].[TAB_MESSAGGI_FIELDS] ADD  CONSTRAINT [DF_TAB_MESSAGGI_FIELDS_NumProduct_PRODUCTS3_rettifiche]  DEFAULT ('') FOR [NumProduct_PRODUCTS3_rettifiche]
GO
