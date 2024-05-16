USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[IdPfu] [int] NULL,
	[TipoOperAnag] [nvarchar](200) NULL,
	[Stato] [nvarchar](20) NULL,
	[Protocol] [nvarchar](20) NULL,
	[isOld] [int] NULL,
	[IdAzi] [int] NULL,
	[aziTs] [timestamp] NULL,
	[aziLog] [char](7) NULL,
	[aziDataCreazione] [datetime] NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL,
	[aziRagioneSocialeNorm] [nvarchar](1000) NULL,
	[aziIdDscFormaSoc] [int] NULL,
	[aziPartitaIVA] [nvarchar](20) NULL,
	[aziE_Mail] [nvarchar](255) NULL,
	[aziAcquirente] [smallint] NULL,
	[aziVenditore] [smallint] NULL,
	[aziProspect] [smallint] NULL,
	[aziIndirizzoLeg] [nvarchar](80) NULL,
	[aziIndirizzoOp] [nvarchar](80) NULL,
	[aziLocalitaLeg] [nvarchar](80) NULL,
	[aziLocalitaOp] [nvarchar](80) NULL,
	[aziProvinciaLeg] [nvarchar](80) NULL,
	[aziProvinciaOp] [nvarchar](20) NULL,
	[aziStatoLeg] [nvarchar](80) NULL,
	[aziStatoOp] [nvarchar](20) NULL,
	[aziCAPLeg] [nvarchar](8) NULL,
	[aziCapOp] [nvarchar](8) NULL,
	[aziPrefisso] [nvarchar](10) NULL,
	[aziTelefono1] [nvarchar](20) NULL,
	[aziTelefono2] [nvarchar](20) NULL,
	[aziFAX] [nvarchar](20) NULL,
	[aziIdDscDescrizione] [int] NULL,
	[aziProssimoProtRdo] [smallint] NULL,
	[aziProssimoProtOff] [smallint] NULL,
	[aziGphValueOper] [int] NULL,
	[aziDeleted] [tinyint] NULL,
	[aziDBNumber] [int] NULL,
	[aziAtvAtecord] [varchar](200) NULL,
	[aziSitoWeb] [nvarchar](300) NULL,
	[aziCodEurocredit] [int] NULL,
	[aziProfili] [varchar](20) NULL,
	[aziProvinciaLeg2] [varchar](100) NULL,
	[aziStatoLeg2] [varchar](100) NULL,
	[TipoDocRiconoscimento] [varchar](255) NULL,
	[SessoPF] [varchar](255) NULL,
	[ProvinciaNascitaPF] [varchar](20) NULL,
	[NumeroDocRiconoscimento] [varchar](20) NULL,
	[NomePF] [varchar](255) NULL,
	[LuogoEmissioneDocRic] [varchar](20) NULL,
	[DocRilasciatoDa] [varchar](255) NULL,
	[DataScadenzaDocRic] [datetime] NULL,
	[DataNascitaPF] [datetime] NULL,
	[DataEmissioneDocRic] [datetime] NULL,
	[ComuneNascitaPF] [varchar](30) NULL,
	[CognomePF] [varchar](255) NULL,
	[CategoriaSOA] [varchar](20) NULL,
	[Notes] [varchar](255) NULL,
	[CARClasMercAzienda] [varchar](255) NULL,
	[CARBelongTo] [varchar](20) NULL,
	[codicefiscale] [varchar](255) NULL,
	[ANNOCOSTITUZIONE] [varchar](4) NULL,
	[IscrCCIAA] [varchar](20) NULL,
	[SedeCCIAA] [varchar](50) NULL,
	[NomeRapLeg] [varchar](255) NULL,
	[CognomeRapLeg] [varchar](255) NULL,
	[TelefonoRapLeg] [varchar](20) NULL,
	[EmailRapLeg] [varchar](50) NULL,
	[sysHabilitStartDate] [datetime] NULL,
	[sysHabilitEndDate] [datetime] NULL,
	[PAIndirizzoOp] [varchar](80) NULL,
	[PALocalitaOp] [varchar](80) NULL,
	[PAProvinciaOp] [varchar](5) NULL,
	[PACapOp] [varchar](5) NULL,
	[PAStatoOp] [varchar](50) NULL,
	[ClasseIscriz] [varchar](7000) NULL,
	[ProtGen] [varchar](10) NULL,
	[DataProt] [datetime] NULL,
	[RuoloRapLeg] [varchar](200) NULL,
	[NotaIscrizioneCCIAA] [varchar](255) NULL,
	[Persgiuridica] [varchar](255) NULL,
	[QualitaImprenditore] [varchar](255) NULL,
	[SedeINPS] [varchar](30) NULL,
	[UfficioINPS] [varchar](30) NULL,
	[IndirizzoINPS] [varchar](30) NULL,
	[TelefonoINPS] [varchar](15) NULL,
	[FaxINPS] [varchar](15) NULL,
	[NumINPS] [varchar](20) NULL,
	[SedeINAIL] [varchar](30) NULL,
	[UfficioINAIL] [varchar](30) NULL,
	[IndirizzoINAIL] [varchar](30) NULL,
	[TelefonoINAIL] [varchar](15) NULL,
	[FaxINAIL] [varchar](15) NULL,
	[NumINAIL] [varchar](15) NULL,
	[LocalitaRapLeg] [varchar](30) NULL,
	[ProvinciaRapLeg] [varchar](20) NULL,
	[DataRapLeg] [datetime] NULL,
	[CellulareRapLeg] [varchar](20) NULL,
	[AltraClassificazione] [varchar](500) NULL,
	[ClassificaSOA] [varchar](20) NULL,
	[Qualita] [varchar](20) NULL,
	[SedeEdile] [varchar](30) NULL,
	[UfficioEdile] [varchar](30) NULL,
	[IndirizzoEdile] [varchar](30) NULL,
	[TelefonoEdile] [varchar](15) NULL,
	[FaxEdile] [varchar](15) NULL,
	[NumEdile] [varchar](50) NULL,
	[CFRapLeg] [varchar](40) NULL,
	[NomeDirTec] [varchar](255) NULL,
	[CognomeDirTec] [varchar](255) NULL,
	[TelefonoDirTec] [varchar](20) NULL,
	[EmailRapDirTec] [varchar](50) NULL,
	[RuoloDirTec] [varchar](50) NULL,
	[LocalitaDirTec] [varchar](30) NULL,
	[ProvinciaDirTec] [varchar](20) NULL,
	[DataRapDirTec] [datetime] NULL,
	[CellulareDirTec] [varchar](20) NULL,
	[CFDirTec] [varchar](40) NULL,
	[Banca] [varchar](40) NULL,
	[AgenziaBanca] [varchar](255) NULL,
	[CittaBanca] [varchar](30) NULL,
	[ProvBanca] [varchar](20) NULL,
	[ABIBanca] [varchar](20) NULL,
	[CABBanca] [varchar](20) NULL,
	[CCBanca] [varchar](40) NULL,
	[CINBanca] [varchar](20) NULL,
	[IBAANBanca] [varchar](55) NULL,
	[AttachAttestazioneSOA] [nvarchar](255) NULL,
	[DataAttestazioneSOA] [datetime] NULL,
	[NoteSOA] [text] NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[SettoriCCNL] [varchar](20) NULL,
	[CancellatoDiUfficio] [varchar](20) NULL,
	[TipoDiAmministr] [varchar](5) NULL,
	[GerarchicoSOA] [nvarchar](4000) NULL,
	[PrevDoc] [int] NULL,
	[TIPO_AMM_ER] [varchar](20) NULL,
	[aziLocalitaLeg2] [varchar](100) NULL,
	[Evidenzia] [nvarchar](4000) NULL,
	[aziRegioneLeg] [varchar](100) NULL,
	[aziRegioneLeg2] [varchar](100) NULL,
	[PARTICIPANTID] [varchar](200) NULL,
	[IDNOTIER] [varchar](100) NULL,
	[SetEnteProponente] [bigint] NULL,
	[Attiva_OCP] [varchar](2) NULL,
	[DataAttivazioneOCP] [datetime] NULL,
	[idHeader] [int] NULL,
	[EsitoRiga] [nvarchar](max) NULL,
	[CG44_DITTA_CG18] [varchar](10) NULL,
	[CARCodiceFornitore] [varchar](10) NULL,
	[ResidenzaRapLeg] [nvarchar](100) NULL,
	[IndResidenzaRapLeg] [nvarchar](100) NULL,
	[disabilita_iscriz_peppol] [varchar](10) NULL,
	[CodiceEORI] [varchar](50) NULL,
	[pfuRuoloAziendale] [nvarchar](200) NULL,
	[AllegatoReferente] [nvarchar](500) NULL,
	[SaPersonalitaGiuridica] [int] NULL,
 CONSTRAINT [PK_Document_Aziende] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF_Document_Aziende_Stato]  DEFAULT ('Saved') FOR [Stato]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF_Document_Aziende_isOld]  DEFAULT ((0)) FOR [isOld]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziDa__24AED87A]  DEFAULT (getdate()) FOR [aziDataCreazione]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziId__25A2FCB3]  DEFAULT ((23903)) FOR [aziIdDscFormaSoc]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziAc__269720EC]  DEFAULT ((0)) FOR [aziAcquirente]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziVe__278B4525]  DEFAULT ((2)) FOR [aziVenditore]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziPr__287F695E]  DEFAULT ((0)) FOR [aziProspect]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziPr__29738D97]  DEFAULT ((1)) FOR [aziProssimoProtRdo]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziPr__2A67B1D0]  DEFAULT ((1)) FOR [aziProssimoProtOff]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziGp__2B5BD609]  DEFAULT ((0)) FOR [aziGphValueOper]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  CONSTRAINT [DF__Document___aziDe__2C4FFA42]  DEFAULT ((0)) FOR [aziDeleted]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  DEFAULT ('') FOR [ResidenzaRapLeg]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  DEFAULT ('') FOR [IndResidenzaRapLeg]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  DEFAULT ('') FOR [CodiceEORI]
GO
ALTER TABLE [dbo].[Document_Aziende] ADD  DEFAULT ('') FOR [pfuRuoloAziendale]
GO
