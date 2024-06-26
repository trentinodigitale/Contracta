USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_CONVENZIONE_DEL_PRODOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[View_CONVENZIONE_DEL_PRODOTTI]
AS
select Id as indRow ,Id, IdHeader, 'CONVENZIONE_DEL_PRODOTTI' as TipoDoc, 
Graduatoria, Sorteggio, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, 
ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto,
 CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, 
 UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, 
 NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, 
 AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, 
 TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, 
 ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, 
 CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere, 
 importoBaseAsta, CampoTesto_1, CampoTesto_2, CampoTesto_3, CampoTesto_4, CampoTesto_5, 
 CampoTesto_6, CampoTesto_7, CampoTesto_8, CampoTesto_9, CampoTesto_10, CampoNumerico_1, 
 CampoNumerico_2, CampoNumerico_3, CampoNumerico_4, CampoNumerico_5, CampoNumerico_6, 
 CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, id as idHeaderLotto, 
 CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, 
 PunteggioTecnico, ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, 
 CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, 
 LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, 
 DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, 
 UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO, PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, 
 CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, 
 DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, 
 PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, 
 PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, 
 LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, 
 VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE,
 DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, 
 NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO,
  RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA, 
  PERC_SCONTO_FISSATA_PER_LEGGE, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, 
  ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, ADESIONE_PAYBACK, DescrizioneAIC, 
  ValoreAccessorioTecnico,TipoAcquisto,Subordinato,ArticoliPrimari
  , SelRow, ValoreSconto, ValoreRibasso, PunteggioTecnicoAssegnato, PunteggioTecnicoRiparCriterio, PunteggioTecnicoRiparTotale, Campo_Intero_1, Campo_Intero_2, Campo_Intero_3, Campo_Intero_4, Campo_Intero_5, CODICE_CIVAB, DESCRIZIONE_CIVAB, CODICE_EAN, CODICE_FISCALE_OPERATORE_ECONOMICO, CODICE_FISCALE_PRODUTTORE, CODICE_PARAF, TIPO_REPERTORIO, CampoAllegato_6, CampoAllegato_7, CampoAllegato_8, CampoAllegato_9, CampoAllegato_10, ONERI_SICUREZZA_NR, TIPOLOGIA_FORNITURA, CampoTesto_11, CampoTesto_12, CampoTesto_13, CampoTesto_14, CampoTesto_15, CampoTesto_16, CampoTesto_17, CampoTesto_18, CampoTesto_19, CampoTesto_20, CampoNumerico_11, CampoNumerico_12, CampoNumerico_13, CampoNumerico_14, CampoNumerico_15, CampoNumerico_16, CampoNumerico_17, CampoNumerico_18, CampoNumerico_19, CampoNumerico_20, CampoAllegato_11, CampoAllegato_12, CampoAllegato_13, CampoAllegato_14, CampoAllegato_15, CampoAllegato_16, CampoAllegato_17, CampoAllegato_18, CampoAllegato_19, CampoAllegato_20, Campo_Intero_6, Campo_Intero_7, Campo_Intero_8, Campo_Intero_9, Campo_Intero_10, Campo_Intero_11, Campo_Intero_12, Campo_Intero_13, Campo_Intero_14, Campo_Intero_15, Campo_Intero_16, Campo_Intero_17, Campo_Intero_18, Campo_Intero_19, Campo_Intero_20
	, [PrezzoVenditaConfezioneIvaInclusa], [STERILE], [MONOUSO], [QT_NUM_PRODOTTO_SINGOLO_PEZZO], [PEZZI_PER_CONFEZIONE], [COSTI_MANODOPERA], [PercAgg], [Dominio_SiNo], [Intervallo_0_24], [Dominio_SiNo_2], [Dominio_SiNo_3], [CODIFICA_ARTICOLO_OE_PEZZO_SINGOLO], [PERC_RIBASSO], [Temperatura_minima_di_conservazione], [Temperatura_massima_di_conservazione], [Ftalati_free], [Infiammabile], [Presenza_medicinali], [Sostanza_corrosiva], [Sostanza_tossica], [Sostanza_velenosa], [Classe_di_Rimborsabilita], [ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA3], [PunteggioEconomicoAssegnato], [Dominio_SiNo_4], [Dominio_SiNo_5], [Dominio_SiNo_6], [Dominio_SiNo_7], [Dominio_SiNo_8], [Dominio_SiNo_9], [Dominio_SiNo_10], [Dominio_SiNo_11], [Dominio_SiNo_12], [Dominio_SiNo_13], [Rialzo_Offerta_Unitario], [CODICE_ISO], [CODICE_REF], [COMODATO_DUSO], [CONFEZIONAMENTO_SECONDARIO_ECOCOMPATIBILE], [CONTENUTO_DI_UP_PER_CONFEZIONE], [DEFINED_DAILY_DOSE], [DENOMINAZIONE_ARTICOLO_COMPLETA], [DENOMINAZIONE_ARTICOLO_SINTETICA], [DENOMINAZIONE_COMMERCIALE], [DESCRIZIONE_COMPLETA_PARAF_BDF], [DOSAGGIO_QTA_PER_PRINCIPIO_ATTIVO], [FARMACO_ESCLUSIVO], [FATTORE_PRODUTTIVO], [INCLUSIONE_PHT], [NUMERO_UNITA_POSOLOGICA_CONTENUTA_INT_BANCALE], [PREZZO_AL_PUBBLICO_PER_CONFEZIONEivainclusa], [SCADENZA_BREVETTO], [SCHEDA_DI_SICUREZZA], [SCHEDA_TECNICA_PRODOTTO], [VALORE_UNITARIO_OFFERTO_IVA_ESCLUSA], [IMPORTO_OPZIONI], [IMPORTO_ATTUAZIONE_SICUREZZA], [PROGRESSIVO_RIGA], [DATA_CONSEGNA], [CODICE_WBS], [DESCRIZIONE_WBS]
	, [DICHIARAZIONE_LATEX_GLUTEN_LACTOS_FREE], [PRODOTTO_IN_ESCLUSIVA], [ELENCO_AIC_DISPONIBILI], [PRESENZA_DI_GLUTINE], [PRESENZA_DI_LATTOSIO], [ALL_FIELD], [ClasseIscriz_S], [AREA_DI_CONSEGNA], [FotoProdotto], [IdRigaRiferimento], [MULTIPLI_ORDINABILI], [TAGLIA], [MODALITA_DI_CONSERVAZIONE], [CODICE_DM_PMC], [SCHEDA_TECNICA_LINK], [CODICE_BDR], [MODALITA_DI_CONSERVAZIONE_DOM]
	--campi Export listini ampiezza di gamma
	,AmpiezzaGamma, FabbisognoTotale, Tipo_Prodotto, ReferenteFornitore, TIPOLOGIA_DM, ClasseCE, CodiceAttribuitoFabbricante, NomeCommercialeModello, PartitaIVAFabbricante, RagioneSocialeFabbricante, TipoMedicinale, 
	QuantitaMinimaGara, prezzoOffertoIvaEsclusa, UnitadiMisuraAcquisto, PrezzoAcquistoIVAesclusa, CodiceSmaltimento, TipizzazioneProdotto, Temperatura, ClassificazioneADR, VitaUtileReferenza, NoteABS


from Document_MicroLotti_Dettagli with (nolock) 
where tipodoc in ( 'CONVENZIONE' , 'LISTINO_ORDINI')



GO
