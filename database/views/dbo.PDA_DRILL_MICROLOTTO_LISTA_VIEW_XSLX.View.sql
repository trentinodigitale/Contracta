USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_DRILL_MICROLOTTO_LISTA_VIEW_XSLX]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[PDA_DRILL_MICROLOTTO_LISTA_VIEW_XSLX] as
	
	select 	
		
		--[IdRowLottoBando] as IdHeader, 
		--[aziRagioneSociale], [Id], [TipoDoc], [Graduatoria], [Sorteggio], [Posizione], [Aggiudicata], [Exequo], [StatoRiga], 
		--[EsitoRiga], [ValoreOfferta], [NumeroLotto], [Descrizione], [Qty], [PrezzoUnitario], [CauzioneMicrolotto], [CIG], [CodiceATC], 
		--[PrincipioAttivo], [FormaFarmaceutica], [Dosaggio], [Somministrazione], [UnitadiMisura], [Quantita], [ImportoBaseAstaUnitaria], 
		--[ImportoAnnuoLotto], [ImportoTriennaleLotto], [NoteLotto], [CodiceAIC], [QuantitaConfezione], [ClasseRimborsoMedicinale], 
		--[PrezzoVenditaConfezione], [AliquotaIva], [ScontoUlteriore], [EstremiGURI], [PrezzoUnitarioOfferta], [PrezzoUnitarioRiferimento], 
		--[TotaleOffertaUnitario], [ScorporoIVA], [PrezzoVenditaConfezioneIvaEsclusa], [PrezzoVenditaUnitario], [ScontoOffertoUnitario], [ScontoObbligatorioUnitario], [DenominazioneProdotto], [RagSocProduttore], [CodiceProdotto], [MarcaturaCE], [NumeroRepertorio], [NumeroCampioni], [Versamento], [PrezzoInLettere], [importoBaseAsta], [CampoTesto_1], [CampoTesto_2], [CampoTesto_3], [CampoTesto_4], [CampoTesto_5], [CampoTesto_6], [CampoTesto_7], [CampoTesto_8], [CampoTesto_9], [CampoTesto_10], [CampoNumerico_1], [CampoNumerico_2], [CampoNumerico_3], [CampoNumerico_4], [CampoNumerico_5], [CampoNumerico_6], [CampoNumerico_7], [CampoNumerico_8], [CampoNumerico_9], [CampoNumerico_10], [Voce], [idHeaderLotto], [CampoAllegato_1], [CampoAllegato_2], [CampoAllegato_3], [CampoAllegato_4], [CampoAllegato_5], [NumeroRiga], [PunteggioTecnico], [ValoreEconomico], [PesoVoce], [ValoreImportoLotto], [Variante], [CONTRATTO], [CODICE_AZIENDA_SANITARIA], [CODICE_REGIONALE], [DESCRIZIONE_CODICE_REGIONALE], [TARGET], [MATERIALE], [LATEX_FREE], [MISURE], [VOLUME], [ALTRE_CARATTERISTICHE], [CONFEZIONAMENTO_PRIMARIO], [PESO_CONFEZIONE], [DIMENSIONI_CONFEZIONE], [TEMPERATURA_CONSERVAZIONE], [QUANTITA_PRODOTTO_SINGOLO_PEZZO], [UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO], [UM_DOSAGGIO], [PARTITA_IVA_FORNITORE], [RAGIONE_SOCIALE_FORNITORE], [CODICE_ARTICOLO_FORNITORE], [DENOMINAZIONE_ARTICOLO_FORNITORE], [DATA_INIZIO_PERIODO_VALIDITA], [DATA_FINE_PERIODO_VALIDITA], [RIFERIMENTO_TEMPORALE_FABBISOGNO], [FABBISOGNO_PREVISTO], [PREZZO_OFFERTO_PER_UM], [CONTENUTO_DI_UM_CONFEZIONE], [PREZZO_CONFEZIONE_IVA_ESCLUSA], [PREZZO_PEZZO], [SCHEDA_PRODOTTO], [CODICE_CND], [DESCRIZIONE_CND], [CODICE_CPV], [DESCRIZIONE_CODICE_CPV], [LIVELLO], [CERTIFICAZIONI], [CARATTERISTICHE_SOCIALI_AMBIENTALI], [PREZZO_BASE_ASTA_UM_IVA_ESCLUSA], [VALORE_BASE_ASTA_IVA_ESCLUSA], [RAGIONE_SOCIALE_ATTUALE_FORNITORE], [PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE], [DATA_ULTIMO_CONTRATTO], [UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE], [VALORE_COMPLESSIVO_OFFERTA], [NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI], [NOTE_OPERATORE_ECONOMICO], [ONERI_SICUREZZA], [PARTITA_IVA_DEPOSITARIO], [RAGIONE_SOCIALE_DEPOSITARIO], [IDENTIFICATIVO_OGGETTO_INIZIATIVA], [AREA_MERCEOLOGICA], [PERC_SCONTO_FISSATA_PER_LEGGE], [ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1], [ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2], [ADESIONE_PAYBACK], [DescrizioneAIC], [ValoreAccessorioTecnico], [TipoAcquisto], [Subordinato], [ArticoliPrimari], [SelRow], [Erosione], [ValoreSconto], [ValoreRibasso], [PunteggioTecnicoAssegnato], [PunteggioTecnicoRiparCriterio], [PunteggioTecnicoRiparTotale], [Campo_Intero_1], [Campo_Intero_2], [Campo_Intero_3], [Campo_Intero_4], [Campo_Intero_5], [CODICE_CIVAB], [DESCRIZIONE_CIVAB], [CODICE_EAN], [CODICE_FISCALE_OPERATORE_ECONOMICO], [CODICE_FISCALE_PRODUTTORE], [CODICE_PARAF], [TIPO_REPERTORIO], [CampoAllegato_6], [CampoAllegato_7], [CampoAllegato_8], [CampoAllegato_9], [CampoAllegato_10], [ONERI_SICUREZZA_NR], [TIPOLOGIA_FORNITURA], [CampoTesto_11], [CampoTesto_12], [CampoTesto_13], [CampoTesto_14], [CampoTesto_15], [CampoTesto_16], [CampoTesto_17], [CampoTesto_18], [CampoTesto_19], [CampoTesto_20], [CampoNumerico_11], [CampoNumerico_12], [CampoNumerico_13], [CampoNumerico_14], [CampoNumerico_15], [CampoNumerico_16], [CampoNumerico_17], [CampoNumerico_18], [CampoNumerico_19], [CampoNumerico_20], [CampoAllegato_11], [CampoAllegato_12], [CampoAllegato_13], [CampoAllegato_14], [CampoAllegato_15], [CampoAllegato_16], [CampoAllegato_17], [CampoAllegato_18], [CampoAllegato_19], [CampoAllegato_20], [Campo_Intero_6], [Campo_Intero_7], [Campo_Intero_8], [Campo_Intero_9], [Campo_Intero_10], [Campo_Intero_11], [Campo_Intero_12], [Campo_Intero_13], [Campo_Intero_14], [Campo_Intero_15], [Campo_Intero_16], [Campo_Intero_17], [Campo_Intero_18], [Campo_Intero_19], [Campo_Intero_20], [PrezzoVenditaConfezioneIvaInclusa], [STERILE], [MONOUSO], [QT_NUM_PRODOTTO_SINGOLO_PEZZO], [PEZZI_PER_CONFEZIONE], [COSTI_MANODOPERA], [PercAgg], [Dominio_SiNo], [Intervallo_0_24], [Dominio_SiNo_2], [Dominio_SiNo_3], [CODIFICA_ARTICOLO_OE_PEZZO_SINGOLO], [PERC_RIBASSO], [Temperatura_minima_di_conservazione], [Temperatura_massima_di_conservazione], [Ftalati_free], [Infiammabile], [Presenza_medicinali], [Sostanza_corrosiva], [Sostanza_tossica], [Sostanza_velenosa], [Classe_di_Rimborsabilita], [ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA3], [PunteggioEconomicoAssegnato], [PunteggioEconomico], [IdOffertaLotto], [Motivazione], [idMsg], [OPEN_DOC_NAME], [idPDA], [bRead], [bReadEconomica], [NumRiga], [aziPartitaIVA], [aziLocalitaLeg], [aziE_Mail], [PrzBaseAsta], [PercentualeRibasso], [Ribasso], [StatoPDA], [InversioneBuste]
		--,ordinamento
	
			[IdRowLottoBando] as IdHeader,NumeroLotto, isnull(ml.ML_Description, vals.DMV_DescML) as CampoTesto_1 ,
			aziRagioneSociale, isnull(ml2.ML_Description, vals2.DMV_DescML) as CampoTesto_2,Graduatoria, ValoreOfferta,
			PunteggioTecnico,PunteggioEconomico,ValoreImportoLotto,Sorteggio,cast( numriga as int) as numriga, 'BANDO_GARA' as tipodoc, 
			PrzBaseAsta, PercentualeRibasso, Ribasso,
			Voce,statoRiga,InversioneBuste,ValoreSconto,Ordinamento
		from 

		PDA_DRILL_MICROLOTTO_LISTA_VIEW
			left join LIB_DomainValues vals with(nolock) on vals.DMV_DM_ID = 'StatoRiga' and vals.DMV_Cod = StatoRiga
			left outer join dbo.LIB_Multilinguismo ml with(nolock) ON vals.DMV_DescML = ml.ML_KEY and ml.ML_LNG = 'I'

			left join LIB_DomainValues vals2 with(nolock) on vals2.DMV_DM_ID = 'Posizione' and vals2.DMV_Cod = Posizione
			left outer join dbo.LIB_Multilinguismo ml2 with(nolock) ON vals2.DMV_DescML = ml2.ML_KEY and ml2.ML_LNG = 'I'

	where Voce = 0 and statoRiga <> 'escluso'  

GO
