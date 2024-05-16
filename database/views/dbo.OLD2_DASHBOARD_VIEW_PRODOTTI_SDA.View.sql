USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_PRODOTTI_SDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_DASHBOARD_VIEW_PRODOTTI_SDA] as
select  
	d.id as IdFrom,
	BD.id as indRow,
	BD.id,
	BD.IdHeader, 'BANDO_SEMPLIFICATO' as TipoDoc, BD.Graduatoria, BD.Sorteggio, BD.Posizione, BD.Aggiudicata, BD.Exequo, BD.StatoRiga, BD.EsitoRiga, BD.ValoreOfferta, BD.NumeroLotto, 
	BD.Descrizione, BD.Qty, BD.PrezzoUnitario, BD.CauzioneMicrolotto, BD.CIG, BD.CodiceATC, BD.PrincipioAttivo, BD.FormaFarmaceutica, BD.Dosaggio, BD.Somministrazione, 
	BD.UnitadiMisura, BD.Quantita, BD.ImportoBaseAstaUnitaria, BD.ImportoAnnuoLotto, BD.ImportoTriennaleLotto, BD.NoteLotto, BD.CodiceAIC, BD.QuantitaConfezione, BD.ClasseRimborsoMedicinale, 
	BD.PrezzoVenditaConfezione, BD.AliquotaIva, BD.ScontoUlteriore, BD.EstremiGURI, BD.PrezzoUnitarioOfferta, BD.PrezzoUnitarioRiferimento, BD.TotaleOffertaUnitario, 
	BD.ScorporoIVA, BD.PrezzoVenditaConfezioneIvaEsclusa, BD.PrezzoVenditaUnitario, BD.ScontoOffertoUnitario, BD.ScontoObbligatorioUnitario, BD.DenominazioneProdotto, 
	BD.RagSocProduttore, BD.CodiceProdotto, BD.MarcaturaCE, BD.NumeroRepertorio, BD.NumeroCampioni, BD.Versamento, BD.PrezzoInLettere, BD.importoBaseAsta, CampoTesto_1, CampoTesto_2, CampoTesto_3, CampoTesto_4, CampoTesto_5, CampoTesto_6, CampoTesto_7, CampoTesto_8, CampoTesto_9, CampoTesto_10, CampoNumerico_1, CampoNumerico_2, CampoNumerico_3, CampoNumerico_4, CampoNumerico_5, CampoNumerico_6, CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico, ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO, PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO, RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA, PERC_SCONTO_FISSATA_PER_LEGGE, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, ADESIONE_PAYBACK, DescrizioneAIC, ValoreAccessorioTecnico, TipoAcquisto, Subordinato, ArticoliPrimari
	
from CTL_DOC  d 
		inner join dbo.Document_Bando s on id = idheader
		inner join document_microlotti_dettagli BD on BD.idheader=d.id
	where d.tipodoc='bando_sda'	and deleted=0 and statofunzionale='pubblicato'

GO
