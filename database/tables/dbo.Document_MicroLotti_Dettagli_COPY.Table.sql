USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_MicroLotti_Dettagli_COPY]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_MicroLotti_Dettagli_COPY](
	[Id] [int] NOT NULL,
	[IdHeader] [int] NOT NULL,
	[TipoDoc] [varchar](50) NOT NULL,
	[Graduatoria] [int] NULL,
	[Sorteggio] [float] NULL,
	[Posizione] [varchar](50) NULL,
	[Aggiudicata] [int] NULL,
	[Exequo] [int] NULL,
	[StatoRiga] [varchar](50) NOT NULL,
	[EsitoRiga] [nvarchar](4000) NULL,
	[ValoreOfferta] [nvarchar](100) NULL,
	[NumeroLotto] [varchar](50) NULL,
	[Descrizione] [nvarchar](1000) NULL,
	[Qty] [float] NULL,
	[PrezzoUnitario] [varchar](50) NULL,
	[CauzioneMicrolotto] [float] NULL,
	[CIG] [nvarchar](50) NULL,
	[CodiceATC] [nvarchar](20) NULL,
	[PrincipioAttivo] [nvarchar](255) NULL,
	[FormaFarmaceutica] [nvarchar](50) NULL,
	[Dosaggio] [nvarchar](50) NULL,
	[Somministrazione] [nvarchar](100) NULL,
	[UnitadiMisura] [nvarchar](50) NULL,
	[Quantita] [float] NULL,
	[ImportoBaseAstaUnitaria] [float] NULL,
	[ImportoAnnuoLotto] [float] NULL,
	[ImportoTriennaleLotto] [float] NULL,
	[NoteLotto] [ntext] NULL,
	[CodiceAIC] [nvarchar](50) NULL,
	[QuantitaConfezione] [float] NULL,
	[ClasseRimborsoMedicinale] [nvarchar](50) NULL,
	[PrezzoVenditaConfezione] [float] NULL,
	[AliquotaIva] [float] NULL,
	[ScontoUlteriore] [float] NULL,
	[EstremiGURI] [nvarchar](255) NULL,
	[PrezzoUnitarioOfferta] [nvarchar](100) NULL,
	[PrezzoUnitarioRiferimento] [float] NULL,
	[TotaleOffertaUnitario] [nvarchar](100) NULL,
	[ScorporoIVA] [float] NULL,
	[PrezzoVenditaConfezioneIvaEsclusa] [float] NULL,
	[PrezzoVenditaUnitario] [float] NULL,
	[ScontoOffertoUnitario] [nvarchar](100) NULL,
	[ScontoObbligatorioUnitario] [float] NULL,
	[DenominazioneProdotto] [nvarchar](150) NULL,
	[RagSocProduttore] [nvarchar](150) NULL,
	[CodiceProdotto] [nvarchar](100) NULL,
	[MarcaturaCE] [nvarchar](100) NULL,
	[NumeroRepertorio] [nvarchar](50) NULL,
	[NumeroCampioni] [int] NULL,
	[Versamento] [float] NULL,
	[PrezzoInLettere] [nvarchar](500) NULL,
	[importoBaseAsta] [float] NULL,
	[CampoTesto_1] [nvarchar](max) NULL,
	[CampoTesto_2] [nvarchar](max) NULL,
	[CampoTesto_3] [nvarchar](max) NULL,
	[CampoTesto_4] [nvarchar](max) NULL,
	[CampoTesto_5] [nvarchar](max) NULL,
	[CampoTesto_6] [nvarchar](max) NULL,
	[CampoTesto_7] [nvarchar](max) NULL,
	[CampoTesto_8] [nvarchar](max) NULL,
	[CampoTesto_9] [nvarchar](max) NULL,
	[CampoTesto_10] [nvarchar](max) NULL,
	[CampoNumerico_1] [float] NULL,
	[CampoNumerico_2] [float] NULL,
	[CampoNumerico_3] [float] NULL,
	[CampoNumerico_4] [float] NULL,
	[CampoNumerico_5] [float] NULL,
	[CampoNumerico_6] [float] NULL,
	[CampoNumerico_7] [float] NULL,
	[CampoNumerico_8] [float] NULL,
	[CampoNumerico_9] [float] NULL,
	[CampoNumerico_10] [float] NULL,
	[Voce] [int] NULL,
	[idHeaderLotto] [int] NULL,
	[CampoAllegato_1] [nvarchar](250) NULL,
	[CampoAllegato_2] [nvarchar](250) NULL,
	[CampoAllegato_3] [nvarchar](250) NULL,
	[CampoAllegato_4] [nvarchar](250) NULL,
	[CampoAllegato_5] [nvarchar](250) NULL,
	[NumeroRiga] [int] NULL,
	[PunteggioTecnico] [float] NULL,
	[ValoreEconomico] [float] NULL,
	[PesoVoce] [float] NULL,
	[ValoreImportoLotto] [float] NULL,
	[Variante] [int] NULL,
	[CONTRATTO] [nvarchar](100) NULL,
	[CODICE_AZIENDA_SANITARIA] [nvarchar](100) NULL,
	[CODICE_REGIONALE] [nvarchar](100) NULL,
	[DESCRIZIONE_CODICE_REGIONALE] [nvarchar](500) NULL,
	[TARGET] [nvarchar](100) NULL,
	[MATERIALE] [nvarchar](100) NULL,
	[LATEX_FREE] [nvarchar](10) NULL,
	[MISURE] [nvarchar](100) NULL,
	[VOLUME] [float] NULL,
	[ALTRE_CARATTERISTICHE] [nvarchar](500) NULL,
	[CONFEZIONAMENTO_PRIMARIO] [nvarchar](100) NULL,
	[PESO_CONFEZIONE] [float] NULL,
	[DIMENSIONI_CONFEZIONE] [nvarchar](150) NULL,
	[TEMPERATURA_CONSERVAZIONE] [float] NULL,
	[QUANTITA_PRODOTTO_SINGOLO_PEZZO] [nvarchar](150) NULL,
	[UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO] [nvarchar](100) NULL,
	[UM_DOSAGGIO] [nvarchar](100) NULL,
	[PARTITA_IVA_FORNITORE] [nvarchar](50) NULL,
	[RAGIONE_SOCIALE_FORNITORE] [nvarchar](450) NULL,
	[CODICE_ARTICOLO_FORNITORE] [nvarchar](100) NULL,
	[DENOMINAZIONE_ARTICOLO_FORNITORE] [nvarchar](250) NULL,
	[DATA_INIZIO_PERIODO_VALIDITA] [datetime] NULL,
	[DATA_FINE_PERIODO_VALIDITA] [datetime] NULL,
	[RIFERIMENTO_TEMPORALE_FABBISOGNO] [nvarchar](100) NULL,
	[FABBISOGNO_PREVISTO] [float] NULL,
	[PREZZO_OFFERTO_PER_UM] [float] NULL,
	[CONTENUTO_DI_UM_CONFEZIONE] [nvarchar](100) NULL,
	[PREZZO_CONFEZIONE_IVA_ESCLUSA] [float] NULL,
	[PREZZO_PEZZO] [float] NULL,
	[SCHEDA_PRODOTTO] [nvarchar](250) NULL,
	[CODICE_CND] [nvarchar](250) NULL,
	[DESCRIZIONE_CND] [nvarchar](250) NULL,
	[CODICE_CPV] [nvarchar](250) NULL,
	[DESCRIZIONE_CODICE_CPV] [nvarchar](500) NULL,
	[LIVELLO] [nvarchar](250) NULL,
	[CERTIFICAZIONI] [nvarchar](250) NULL,
	[CARATTERISTICHE_SOCIALI_AMBIENTALI] [nvarchar](250) NULL,
	[PREZZO_BASE_ASTA_UM_IVA_ESCLUSA] [float] NULL,
	[VALORE_BASE_ASTA_IVA_ESCLUSA] [float] NULL,
	[RAGIONE_SOCIALE_ATTUALE_FORNITORE] [nvarchar](450) NULL,
	[PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE] [float] NULL,
	[DATA_ULTIMO_CONTRATTO] [datetime] NULL,
	[UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE] [float] NULL,
	[VALORE_COMPLESSIVO_OFFERTA] [float] NULL,
	[NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI] [varchar](500) NULL,
	[NOTE_OPERATORE_ECONOMICO] [varchar](500) NULL,
	[ONERI_SICUREZZA] [varchar](250) NULL,
	[PARTITA_IVA_DEPOSITARIO] [varchar](250) NULL,
	[RAGIONE_SOCIALE_DEPOSITARIO] [varchar](450) NULL,
	[IDENTIFICATIVO_OGGETTO_INIZIATIVA] [varchar](250) NULL,
	[AREA_MERCEOLOGICA] [varchar](250) NULL,
	[PERC_SCONTO_FISSATA_PER_LEGGE] [float] NULL,
	[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1] [float] NULL,
	[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2] [float] NULL,
	[ADESIONE_PAYBACK] [varchar](10) NULL,
	[DescrizioneAIC] [nvarchar](500) NULL,
	[ValoreAccessorioTecnico] [float] NULL,
	[TipoAcquisto] [varchar](100) NULL,
	[Subordinato] [varchar](50) NULL,
	[ArticoliPrimari] [nvarchar](1000) NULL,
	[SelRow] [varchar](1) NULL,
	[Erosione] [varchar](2) NULL,
	[ValoreSconto] [float] NULL,
	[ValoreRibasso] [float] NULL,
	[PunteggioTecnicoAssegnato] [float] NULL,
	[PunteggioTecnicoRiparCriterio] [float] NULL,
	[PunteggioTecnicoRiparTotale] [float] NULL,
	[Campo_Intero_1] [int] NULL,
	[Campo_Intero_2] [int] NULL,
	[Campo_Intero_3] [int] NULL,
	[Campo_Intero_4] [int] NULL,
	[Campo_Intero_5] [int] NULL,
	[CODICE_CIVAB] [varchar](100) NULL,
	[DESCRIZIONE_CIVAB] [varchar](1000) NULL,
	[CODICE_EAN] [varchar](100) NULL,
	[CODICE_FISCALE_OPERATORE_ECONOMICO] [varchar](50) NULL,
	[CODICE_FISCALE_PRODUTTORE] [varchar](50) NULL,
	[CODICE_PARAF] [varchar](100) NULL,
	[TIPO_REPERTORIO] [varchar](100) NULL,
	[CampoAllegato_6] [nvarchar](250) NULL,
	[CampoAllegato_7] [nvarchar](250) NULL,
	[CampoAllegato_8] [nvarchar](250) NULL,
	[CampoAllegato_9] [nvarchar](250) NULL,
	[CampoAllegato_10] [nvarchar](250) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
