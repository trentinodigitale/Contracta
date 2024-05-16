USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_View_CONVENZIONE_UPD_PRODOTTI_OLD]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_View_CONVENZIONE_UPD_PRODOTTI_OLD]
AS
select Id as indRow ,Id, IdHeader, 'CONVENZIONE_UPD_PRODOTTI_OLD' as TipoDoc, 
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
 CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, Id as idHeaderLotto, 
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
	

from Document_MicroLotti_Dettagli





GO
