USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ODC]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ODC](
	[RDA_IdRow] [int] IDENTITY(1,1) NOT NULL,
	[RDA_ID] [int] NOT NULL,
	[RDA_Owner] [varchar](20) NULL,
	[RDA_Name] [nvarchar](1000) NULL,
	[RDA_DataCreazione] [datetime] NULL,
	[RDA_Protocol] [nvarchar](50) NULL,
	[RDA_Object] [nvarchar](max) NULL,
	[RDA_Total] [float] NULL,
	[RDA_Stato] [varchar](50) NULL,
	[RDA_AZI] [nvarchar](10) NULL,
	[RDA_Plant_CDC] [nvarchar](50) NULL,
	[RDA_Valuta] [nvarchar](50) NULL,
	[RDA_InBudget] [nvarchar](10) NULL,
	[RDA_BDG_Periodo] [varchar](10) NULL,
	[RDA_Deleted] [char](1) NULL,
	[RDA_BuyerRole] [nvarchar](20) NULL,
	[RDA_ResidualBudget] [float] NULL,
	[RDA_CEO] [nvarchar](10) NULL,
	[_RDA_SOCRic] [nvarchar](10) NULL,
	[_RDA_PlantRic] [nvarchar](50) NULL,
	[RDA_MCE] [nvarchar](10) NULL,
	[RDA_DataScad] [datetime] NULL,
	[RDA_Utilizzo] [nvarchar](20) NULL,
	[RDA_Type] [nvarchar](20) NULL,
	[RDA_IT] [nvarchar](20) NULL,
	[RDA_Origin_InBudget] [nvarchar](10) NULL,
	[RDAC_Type] [nvarchar](20) NULL,
	[TipoInvestimento] [nvarchar](20) NULL,
	[PayBack] [float] NULL,
	[ROI] [float] NULL,
	[IRR] [float] NULL,
	[TotalEURO] [float] NULL,
	[RDA_FirstApprover] [varchar](20) NULL,
	[Emergenza] [int] NULL,
	[Ratifica] [varchar](20) NULL,
	[DataRatifica] [datetime] NULL,
	[idPfuRatifica] [int] NULL,
	[Allegato] [nvarchar](255) NULL,
	[RDA_Fornitore] [int] NULL,
	[NumeroFattura] [nvarchar](20) NULL,
	[J_DataConsegna] [int] NULL,
	[RDA_TypeApp] [nvarchar](20) NULL,
	[RDA_OLD_DOC_RDA_ID] [int] NULL,
	[RDA_OLD_DOC_TYPE] [nvarchar](20) NULL,
	[Utente] [int] NULL,
	[Plant] [nvarchar](50) NULL,
	[IVA] [int] NULL,
	[IdAziDest] [int] NULL,
	[ImpegnoSpesa] [nvarchar](200) NULL,
	[TotalIva] [float] NULL,
	[ODC_PEG] [varchar](50) NULL,
	[Capitolo] [varchar](20) NULL,
	[NumeroConvenzione] [varchar](20) NULL,
	[ReferenteConsegna] [nvarchar](50) NULL,
	[ReferenteIndirizzo] [nvarchar](50) NULL,
	[ReferenteTelefono] [nvarchar](50) NULL,
	[ReferenteEMail] [nvarchar](50) NULL,
	[ReferenteRitiro] [nvarchar](50) NULL,
	[IndirizzoRitiro] [nvarchar](50) NULL,
	[TelefonoRitiro] [nvarchar](50) NULL,
	[Id_Convenzione] [int] NULL,
	[RitiroEMail] [varchar](100) NULL,
	[RefOrd] [varchar](100) NULL,
	[RefOrdInd] [varchar](200) NULL,
	[RefOrdTel] [varchar](20) NULL,
	[RefOrdEMail] [varchar](100) NULL,
	[RDP_DataPrevCons] [datetime] NULL,
	[TipoOrdine] [nchar](1) NULL,
	[NoMail] [char](1) NULL,
	[Id_Preventivo] [int] NULL,
	[AllegatoConsegna] [nvarchar](255) NULL,
	[TipoImporto] [varchar](100) NULL,
	[FuoriPiattaforma] [varchar](2) NULL,
	[SIGN_HASH] [varchar](255) NULL,
	[SIGN_ATTACH] [nvarchar](255) NULL,
	[SIGN_LOCK] [int] NULL,
	[UserRUP] [int] NULL,
	[NotEditable] [varchar](500) NULL,
	[ReferenteStato] [nvarchar](500) NULL,
	[ReferenteProvincia] [nvarchar](500) NULL,
	[ReferenteLocalita] [nvarchar](500) NULL,
	[ReferenteCap] [nvarchar](50) NULL,
	[FatturazioneStato] [nvarchar](500) NULL,
	[FatturazioneProvincia] [nvarchar](500) NULL,
	[FatturazioneLocalita] [nvarchar](500) NULL,
	[FatturazioneCap] [nvarchar](50) NULL,
	[ReferenteStato2] [nvarchar](100) NULL,
	[ReferenteProvincia2] [nvarchar](100) NULL,
	[ReferenteLocalita2] [nvarchar](100) NULL,
	[FattuarzioneStato2] [nvarchar](100) NULL,
	[FatturazioneProvincia2] [nvarchar](100) NULL,
	[FatturazioneLocalita2] [nvarchar](100) NULL,
	[DataStipulaConvenzione] [datetime] NULL,
	[CIG] [varchar](50) NULL,
	[TotaleValoreAccessorio] [float] NULL,
	[EsistonoIntegrazioni] [char](1) NULL,
	[IdDocIntegrato] [int] NULL,
	[NumeroMesi] [int] NULL,
	[CodiceIPA] [varchar](50) NULL,
	[TotaleEroso] [float] NULL,
	[TotalIvaEroso] [float] NULL,
	[IdDocRidotto] [int] NULL,
	[CIG_MADRE] [nvarchar](50) NULL,
	[RichiestaCigSimog] [varchar](2) NULL,
	[idpfuRup] [varchar](50) NULL,
	[Obbligo_Cig_Derivato] [varchar](10) NULL,
	[Motivazione_ObbligoCigDerivato] [ntext] NULL,
	[Appalto_PNRR] [varchar](10) NULL,
	[Appalto_PNC] [varchar](10) NULL,
	[Motivazione_Appalto_PNRR] [text] NULL,
	[Motivazione_Appalto_PNC] [text] NULL,
	[TipoAppaltoGara] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF_Document_ODC_RDA_Stato]  DEFAULT ('Saved') FOR [RDA_Stato]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_I__4323150B]  DEFAULT (' ') FOR [RDA_InBudget]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_D__44173944]  DEFAULT (' ') FOR [RDA_Deleted]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_R__450B5D7D]  DEFAULT ((0)) FOR [RDA_ResidualBudget]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_C__45FF81B6]  DEFAULT (' ') FOR [RDA_CEO]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document____RDA___46F3A5EF]  DEFAULT ('') FOR [_RDA_SOCRic]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document____RDA___47E7CA28]  DEFAULT ('') FOR [_RDA_PlantRic]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_M__48DBEE61]  DEFAULT (' ') FOR [RDA_MCE]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_T__49D0129A]  DEFAULT ('1') FOR [RDA_Type]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_I__4AC436D3]  DEFAULT ('no') FOR [RDA_IT]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_O__4BB85B0C]  DEFAULT (' ') FOR [RDA_Origin_InBudget]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDAC___4CAC7F45]  DEFAULT ((1)) FOR [RDAC_Type]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_F__4DA0A37E]  DEFAULT ('') FOR [RDA_FirstApprover]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___Emerg__4E94C7B7]  DEFAULT ((0)) FOR [Emergenza]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___Ratif__4F88EBF0]  DEFAULT ('') FOR [Ratifica]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___J_Dat__507D1029]  DEFAULT ((0)) FOR [J_DataConsegna]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_T__51713462]  DEFAULT ((1)) FOR [RDA_TypeApp]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___RDA_O__5265589B]  DEFAULT ((0)) FOR [RDA_OLD_DOC_RDA_ID]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF_Document_ODC_FuoriPiattaforma]  DEFAULT ('no') FOR [FuoriPiattaforma]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF_Document_ODC_SIGN_ATTACH]  DEFAULT ('') FOR [SIGN_ATTACH]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF_Document_ODC_SIGN_LOCK]  DEFAULT ((0)) FOR [SIGN_LOCK]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  CONSTRAINT [DF__Document___IdDoc__3B2F1994]  DEFAULT ((0)) FOR [IdDocIntegrato]
GO
ALTER TABLE [dbo].[Document_ODC] ADD  DEFAULT ('') FOR [CIG_MADRE]
GO
