USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SCRITTURA_PRIVATA_BENI_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_SCRITTURA_PRIVATA_BENI_VIEW] AS
select 
	 D.[Id], D.[IdHeader], D.[TipoDoc], D.[Graduatoria], D.[Sorteggio], 
	 D.[Posizione], D.[Aggiudicata], D.[Exequo], D.[StatoRiga], D.[ValoreOfferta],
	 D.[NumeroLotto], D.[Descrizione], D.[Qty], D.[PrezzoUnitario], D.[CauzioneMicrolotto],
	 D.[CIG], D.[CodiceATC], D.[PrincipioAttivo], D.[FormaFarmaceutica], D.[Dosaggio],
	 D.[Somministrazione], D.[UnitadiMisura], D.[Quantita], D.[ImportoBaseAstaUnitaria], 
	 D.[ImportoAnnuoLotto], D.[ImportoTriennaleLotto], D.[NoteLotto], D.[CodiceAIC], D.[QuantitaConfezione], 
	 D.[ClasseRimborsoMedicinale], D.[PrezzoVenditaConfezione], D.[AliquotaIva], D.[ScontoUlteriore], 
	 D.[EstremiGURI], D.[PrezzoUnitarioOfferta], D.[PrezzoUnitarioRiferimento], D.[TotaleOffertaUnitario], D.[ScorporoIVA], 
	 D.[PrezzoVenditaConfezioneIvaEsclusa], D.[PrezzoVenditaUnitario], D.[ScontoOffertoUnitario], D.[ScontoObbligatorioUnitario], 
	 D.[DenominazioneProdotto], D.[RagSocProduttore], D.[CodiceProdotto], D.[MarcaturaCE], D.[NumeroRepertorio], D.[NumeroCampioni], 
	 D.[Versamento], D.[PrezzoInLettere], D.[importoBaseAsta], D.[CampoTesto_1], D.[CampoTesto_2], D.[CampoTesto_3], D.[CampoTesto_4], D.[CampoTesto_5], 
	 D.[CampoTesto_6], D.[CampoTesto_7], D.[CampoTesto_8], D.[CampoTesto_9], D.[CampoTesto_10], D.[CampoNumerico_1], D.[CampoNumerico_2], D.[CampoNumerico_3], 
	 D.[CampoNumerico_4], D.[CampoNumerico_5], D.[CampoNumerico_6], D.[CampoNumerico_7], D.[CampoNumerico_8], D.[CampoNumerico_9], D.[CampoNumerico_10], 
	 D.[Voce], D.[idHeaderLotto], D.[CampoAllegato_1], D.[CampoAllegato_2], D.[CampoAllegato_3], D.[CampoAllegato_4], D.[CampoAllegato_5], D.[NumeroRiga], 
	 D.[PunteggioTecnico], D.[ValoreEconomico], D.[PesoVoce], D.[ValoreImportoLotto], D.[Variante], D.[CONTRATTO], D.[CODICE_AZIENDA_SANITARIA], 
	 D.[CODICE_REGIONALE], D.[DESCRIZIONE_CODICE_REGIONALE], D.[TARGET], D.[MATERIALE], D.[LATEX_FREE], D.[MISURE], D.[VOLUME], D.[ALTRE_CARATTERISTICHE], 
	 D.[CONFEZIONAMENTO_PRIMARIO], D.[PESO_CONFEZIONE], D.[DIMENSIONI_CONFEZIONE], D.[TEMPERATURA_CONSERVAZIONE], D.[QUANTITA_PRODOTTO_SINGOLO_PEZZO], 
	 D.[UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO], D.[UM_DOSAGGIO], D.[PARTITA_IVA_FORNITORE], D.[RAGIONE_SOCIALE_FORNITORE], D.[CODICE_ARTICOLO_FORNITORE], 
	 D.[DENOMINAZIONE_ARTICOLO_FORNITORE], D.[DATA_INIZIO_PERIODO_VALIDITA], D.[DATA_FINE_PERIODO_VALIDITA], D.[RIFERIMENTO_TEMPORALE_FABBISOGNO], 
	 D.[FABBISOGNO_PREVISTO], D.[PREZZO_OFFERTO_PER_UM], D.[CONTENUTO_DI_UM_CONFEZIONE], D.[PREZZO_CONFEZIONE_IVA_ESCLUSA], D.[PREZZO_PEZZO], 
	 D.[SCHEDA_PRODOTTO], D.[CODICE_CND], D.[DESCRIZIONE_CND], D.[CODICE_CPV], D.[DESCRIZIONE_CODICE_CPV], D.[LIVELLO], D.[CERTIFICAZIONI], 
	 D.[CARATTERISTICHE_SOCIALI_AMBIENTALI], D.[PREZZO_BASE_ASTA_UM_IVA_ESCLUSA], D.[VALORE_BASE_ASTA_IVA_ESCLUSA], D.[RAGIONE_SOCIALE_ATTUALE_FORNITORE], 
	 D.[PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE], D.[DATA_ULTIMO_CONTRATTO], D.[UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE], 
	 D.[VALORE_COMPLESSIVO_OFFERTA], D.[NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI], D.[NOTE_OPERATORE_ECONOMICO], D.[ONERI_SICUREZZA], D.[PARTITA_IVA_DEPOSITARIO], 
	 D.[RAGIONE_SOCIALE_DEPOSITARIO], D.[IDENTIFICATIVO_OGGETTO_INIZIATIVA], D.[AREA_MERCEOLOGICA], D.[PERC_SCONTO_FISSATA_PER_LEGGE], 
	 D.[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1], D.[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2], D.[ADESIONE_PAYBACK], D.[DescrizioneAIC], 
	 D.[ValoreAccessorioTecnico], D.[TipoAcquisto], D.[Subordinato], D.[ArticoliPrimari], D.[SelRow], D.[Erosione], D.[ValoreSconto], D.[ValoreRibasso], 
	 D.[PunteggioTecnicoAssegnato], D.[PunteggioTecnicoRiparCriterio], D.[PunteggioTecnicoRiparTotale], D.[Campo_Intero_1], D.[Campo_Intero_2], 
	 D.[Campo_Intero_3], D.[Campo_Intero_4], D.[Campo_Intero_5], D.[CODICE_CIVAB], D.[DESCRIZIONE_CIVAB], D.[CODICE_EAN], D.[CODICE_FISCALE_OPERATORE_ECONOMICO], 
	 D.[CODICE_FISCALE_PRODUTTORE], D.[CODICE_PARAF], D.[TIPO_REPERTORIO], D.[CampoAllegato_6], D.[CampoAllegato_7], D.[CampoAllegato_8], D.[CampoAllegato_9], 
	 D.[CampoAllegato_10], D.[ONERI_SICUREZZA_NR], D.[TIPOLOGIA_FORNITURA], D.[CampoTesto_11], D.[CampoTesto_12], D.[CampoTesto_13], D.[CampoTesto_14], 
	 D.[CampoTesto_15], D.[CampoTesto_16], D.[CampoTesto_17], D.[CampoTesto_18], D.[CampoTesto_19], D.[CampoTesto_20], D.[CampoNumerico_11], 
	 D.[CampoNumerico_12], D.[CampoNumerico_13], D.[CampoNumerico_14], D.[CampoNumerico_15], D.[CampoNumerico_16], D.[CampoNumerico_17], D.[CampoNumerico_18], 
	 D.[CampoNumerico_19], D.[CampoNumerico_20], D.[CampoAllegato_11], D.[CampoAllegato_12], D.[CampoAllegato_13], D.[CampoAllegato_14], D.[CampoAllegato_15], 
	 D.[CampoAllegato_16], D.[CampoAllegato_17], D.[CampoAllegato_18], D.[CampoAllegato_19], D.[CampoAllegato_20], D.[Campo_Intero_6], D.[Campo_Intero_7], 
	 D.[Campo_Intero_8], D.[Campo_Intero_9], D.[Campo_Intero_10], D.[Campo_Intero_11], D.[Campo_Intero_12], D.[Campo_Intero_13], D.[Campo_Intero_14], 
	 D.[Campo_Intero_15], D.[Campo_Intero_16], D.[Campo_Intero_17], D.[Campo_Intero_18], D.[Campo_Intero_19], D.[Campo_Intero_20], 
	 D.[PrezzoVenditaConfezioneIvaInclusa], D.[STERILE], D.[MONOUSO], D.[QT_NUM_PRODOTTO_SINGOLO_PEZZO], D.[PEZZI_PER_CONFEZIONE], 
	 D.[COSTI_MANODOPERA], D.[PercAgg], D.[Dominio_SiNo], D.[Intervallo_0_24], D.[Dominio_SiNo_2], D.[Dominio_SiNo_3], D.[CODIFICA_ARTICOLO_OE_PEZZO_SINGOLO],
	case		
		 when PDA_LOTTI.StatoRiga='AggiudicazioneDef' then '<img src="../images/Domain/State_OK.gif">'
		 else '<img src="../images/Domain/State_Err.gif"><br/> Lotto in aggiudicazione condizionata,<br/> procedere con il termina controlli sulla procedura di aggiudicazione.'
	end as EsitoRiga ,
	PDA_LOTTI.StatoRiga as Statoriga_LOTTO,	
	D.[PERC_RIBASSO],D.[Temperatura_minima_di_conservazione],D.[Temperatura_massima_di_conservazione],D.[Ftalati_free],D.[Infiammabile],D.[Presenza_medicinali],D.[Sostanza_corrosiva],D.[Sostanza_tossica],D.[Sostanza_velenosa],D.[Classe_di_Rimborsabilita],D.[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA3],D.[PunteggioEconomicoAssegnato],D.[Dominio_SiNo_4],D.[Dominio_SiNo_5],D.[Dominio_SiNo_6],D.[Dominio_SiNo_7],D.[Dominio_SiNo_8],D.[Dominio_SiNo_9],D.[Dominio_SiNo_10],D.[Dominio_SiNo_11],D.[Dominio_SiNo_12],D.[Dominio_SiNo_13],D.[Rialzo_Offerta_Unitario],D.[CODICE_ISO],D.[CODICE_REF],D.[COMODATO_DUSO],D.[CONFEZIONAMENTO_SECONDARIO_ECOCOMPATIBILE],D.[CONTENUTO_DI_UP_PER_CONFEZIONE],D.[DEFINED_DAILY_DOSE],D.[DENOMINAZIONE_ARTICOLO_COMPLETA],D.[DENOMINAZIONE_ARTICOLO_SINTETICA],D.[DENOMINAZIONE_COMMERCIALE],D.[DESCRIZIONE_COMPLETA_PARAF_BDF],D.[DOSAGGIO_QTA_PER_PRINCIPIO_ATTIVO],D.[FARMACO_ESCLUSIVO],D.[FATTORE_PRODUTTIVO],D.[INCLUSIONE_PHT],D.[NUMERO_UNITA_POSOLOGICA_CONTENUTA_INT_BANCALE],D.[PREZZO_AL_PUBBLICO_PER_CONFEZIONEivainclusa],D.[SCADENZA_BREVETTO],D.[SCHEDA_DI_SICUREZZA],D.[SCHEDA_TECNICA_PRODOTTO],D.[VALORE_UNITARIO_OFFERTO_IVA_ESCLUSA],D.[IMPORTO_OPZIONI],D.[IMPORTO_ATTUAZIONE_SICUREZZA],D.[PROGRESSIVO_RIGA],D.[DATA_CONSEGNA],D.[CODICE_WBS],D.[DESCRIZIONE_WBS]
	--campi Export listini ampiezza di gamma
	, D.AmpiezzaGamma, D.FabbisognoTotale, D.Tipo_Prodotto, D.ReferenteFornitore, D.TIPOLOGIA_DM, D.ClasseCE, D.CodiceAttribuitoFabbricante, D.NomeCommercialeModello, D.PartitaIVAFabbricante, D.RagioneSocialeFabbricante, D.TipoMedicinale, D.
	QuantitaMinimaGara, D.prezzoOffertoIvaEsclusa, D.UnitadiMisuraAcquisto, D.PrezzoAcquistoIVAesclusa, D.CodiceSmaltimento, D.TipizzazioneProdotto, D.Temperatura, D.ClassificazioneADR, D.VitaUtileReferenza, D.NoteABS


	from Document_MicroLotti_Dettagli  D with(NOLOCK)
			inner join CTL_DOC C with(NOLOCK) on C.Id=D.IdHeader and C.TipoDoc='SCRITTURA_PRIVATA'  --SCRITTURA_PRIVATA
			inner join CTL_DOC CC with(NOLOCK) on CC.Id=C.LinkedDoc --COMUNICAZIONE
			inner join ctl_doc c1   with(nolock) on CC.linkedDoc=c1.id and C1.tipodoc='PDA_MICROLOTTI' ----
			inner join document_microlotti_dettagli PDA_LOTTI with(nolock) on PDA_LOTTI.idheader=c1.id and PDA_LOTTI.tipodoc= 'PDA_MICROLOTTI' and PDA_LOTTI.NumeroLotto=D.NumeroLotto and PDA_LOTTI.voce=0
		where D.TipoDoc='SCRITTURA_PRIVATA'
GO
