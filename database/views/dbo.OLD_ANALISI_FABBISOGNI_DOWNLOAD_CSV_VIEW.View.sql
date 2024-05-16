USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ANALISI_FABBISOGNI_DOWNLOAD_CSV_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_ANALISI_FABBISOGNI_DOWNLOAD_CSV_VIEW] AS

select

	'RICHIESTA' as aziRagioneSociale,
	cast(Id as varchar(100)) + '-' + cast(NumeroRiga as varchar(100)) as id,
	 IdHeader, TipoDoc, Graduatoria, Sorteggio, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere, importoBaseAsta, CampoTesto_1, CampoTesto_2, CampoTesto_3, CampoTesto_4, CampoTesto_5, CampoTesto_6, CampoTesto_7, CampoTesto_8, CampoTesto_9, CampoTesto_10, CampoNumerico_1, CampoNumerico_2, CampoNumerico_3, CampoNumerico_4, CampoNumerico_5, CampoNumerico_6, CampoNumerico_7, CampoNumerico_8, CampoNumerico_9, CampoNumerico_10, Voce, idHeaderLotto, CampoAllegato_1, CampoAllegato_2, CampoAllegato_3, CampoAllegato_4, CampoAllegato_5, NumeroRiga, PunteggioTecnico, ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO, PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO, RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA, PERC_SCONTO_FISSATA_PER_LEGGE, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, ADESIONE_PAYBACK, DescrizioneAIC, ValoreAccessorioTecnico, TipoAcquisto, Subordinato, ArticoliPrimari, SelRow, Erosione, ValoreSconto, ValoreRibasso, PunteggioTecnicoAssegnato, PunteggioTecnicoRiparCriterio, PunteggioTecnicoRiparTotale, Campo_Intero_1, Campo_Intero_2, Campo_Intero_3, Campo_Intero_4, Campo_Intero_5, CODICE_CIVAB, DESCRIZIONE_CIVAB, CODICE_EAN, CODICE_FISCALE_OPERATORE_ECONOMICO, CODICE_FISCALE_PRODUTTORE, CODICE_PARAF, TIPO_REPERTORIO
	 , CampoAllegato_6, CampoAllegato_7, CampoAllegato_8, CampoAllegato_9, CampoAllegato_10, ONERI_SICUREZZA_NR, TIPOLOGIA_FORNITURA, CampoTesto_11, CampoTesto_12, CampoTesto_13, CampoTesto_14, CampoTesto_15, CampoTesto_16, CampoTesto_17, CampoTesto_18, CampoTesto_19, CampoTesto_20, CampoNumerico_11, CampoNumerico_12, CampoNumerico_13, CampoNumerico_14, CampoNumerico_15, CampoNumerico_16, CampoNumerico_17, CampoNumerico_18, CampoNumerico_19, CampoNumerico_20, CampoAllegato_11, CampoAllegato_12, CampoAllegato_13, CampoAllegato_14, CampoAllegato_15, CampoAllegato_16, CampoAllegato_17, CampoAllegato_18, CampoAllegato_19, CampoAllegato_20, Campo_Intero_6, Campo_Intero_7, Campo_Intero_8, Campo_Intero_9, Campo_Intero_10, Campo_Intero_11, Campo_Intero_12, Campo_Intero_13, Campo_Intero_14, Campo_Intero_15, Campo_Intero_16, Campo_Intero_17, Campo_Intero_18, Campo_Intero_19, Campo_Intero_20
	 ,cast(NoteLotto as nvarchar(MAX)) as NoteLotto
	from 
		Document_MicroLotti_Dettagli  with (nolock)

		where tipodoc='ANALISI_FABBISOGNI' 
		
UNION ALL

select

	a.aziRagioneSociale,
	cast(DM.Id as varchar(100)) + '-' + cast(DM1.NumeroRiga+1 as varchar(100)) as id, 
	
	DM.IdHeader, dm.TipoDoc, dm1.Graduatoria, dm1.Sorteggio, dm1.Posizione, dm1.Aggiudicata, dm1.Exequo, dm1.StatoRiga, dm1.EsitoRiga, dm1.ValoreOfferta, 
	dm1.NumeroLotto, dm1.Descrizione, dm1.Qty, dm1.PrezzoUnitario, dm1.CauzioneMicrolotto, dm1.CIG, dm1.CodiceATC, dm1.PrincipioAttivo, dm1.FormaFarmaceutica,
	 dm1.Dosaggio, dm1.Somministrazione, dm1.UnitadiMisura, dm1.Quantita, dm1.ImportoBaseAstaUnitaria, dm1.ImportoAnnuoLotto, dm1.ImportoTriennaleLotto, 
	 dm1.CodiceAIC, dm1.QuantitaConfezione, dm1.ClasseRimborsoMedicinale, dm1.PrezzoVenditaConfezione, dm1.AliquotaIva, dm1.ScontoUlteriore, dm1.EstremiGURI, 
	 dm1.PrezzoUnitarioOfferta, dm1.PrezzoUnitarioRiferimento, dm1.TotaleOffertaUnitario, dm1.ScorporoIVA, dm1.PrezzoVenditaConfezioneIvaEsclusa, 
	 dm1.PrezzoVenditaUnitario, dm1.ScontoOffertoUnitario, dm1.ScontoObbligatorioUnitario, dm1.DenominazioneProdotto, dm1.RagSocProduttore, 
	 dm1.CodiceProdotto, dm1.MarcaturaCE, dm1.NumeroRepertorio, dm1.NumeroCampioni, dm1.Versamento, dm1.PrezzoInLettere, dm1.importoBaseAsta, 
	 dm1.CampoTesto_1, dm1.CampoTesto_2, dm1.CampoTesto_3, dm1.CampoTesto_4, dm1.CampoTesto_5, dm1.CampoTesto_6, dm1.CampoTesto_7,
	  dm1.CampoTesto_8, dm1.CampoTesto_9, dm1.CampoTesto_10, dm1.CampoNumerico_1, dm1.CampoNumerico_2, dm1.CampoNumerico_3, dm1.CampoNumerico_4, 
	  dm1.CampoNumerico_5, dm1.CampoNumerico_6, dm1.CampoNumerico_7, dm1.CampoNumerico_8, dm1.CampoNumerico_9, dm1.CampoNumerico_10, dm1.Voce, 
	  dm1.idHeaderLotto, dm1.CampoAllegato_1, dm1.CampoAllegato_2, dm1.CampoAllegato_3, dm1.CampoAllegato_4, dm1.CampoAllegato_5, dm1.NumeroRiga, 
	  dm1.PunteggioTecnico, dm1.ValoreEconomico, dm1.PesoVoce, dm1.ValoreImportoLotto, dm1.Variante, dm1.CONTRATTO, dm1.CODICE_AZIENDA_SANITARIA, 
	  dm1.CODICE_REGIONALE, dm1.DESCRIZIONE_CODICE_REGIONALE, dm1.TARGET, dm1.MATERIALE, dm1.LATEX_FREE, dm1.MISURE, dm1.VOLUME, dm1.ALTRE_CARATTERISTICHE, 
	  dm1.CONFEZIONAMENTO_PRIMARIO, dm1.PESO_CONFEZIONE, dm1.DIMENSIONI_CONFEZIONE, dm1.TEMPERATURA_CONSERVAZIONE, dm1.QUANTITA_PRODOTTO_SINGOLO_PEZZO, 
	  dm1.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, dm1.UM_DOSAGGIO, dm1.PARTITA_IVA_FORNITORE, dm1.RAGIONE_SOCIALE_FORNITORE, dm1.CODICE_ARTICOLO_FORNITORE,
	   dm1.DENOMINAZIONE_ARTICOLO_FORNITORE, dm1.DATA_INIZIO_PERIODO_VALIDITA, dm1.DATA_FINE_PERIODO_VALIDITA, dm1.RIFERIMENTO_TEMPORALE_FABBISOGNO, 
	   dm1.FABBISOGNO_PREVISTO, dm1.PREZZO_OFFERTO_PER_UM, dm1.CONTENUTO_DI_UM_CONFEZIONE, dm1.PREZZO_CONFEZIONE_IVA_ESCLUSA, dm1.PREZZO_PEZZO, 
	   dm1.SCHEDA_PRODOTTO, dm1.CODICE_CND, dm1.DESCRIZIONE_CND, dm1.CODICE_CPV, dm1.DESCRIZIONE_CODICE_CPV, dm1.LIVELLO, dm1.CERTIFICAZIONI, 
	   dm1.CARATTERISTICHE_SOCIALI_AMBIENTALI, dm1.PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, dm1.VALORE_BASE_ASTA_IVA_ESCLUSA, dm1.RAGIONE_SOCIALE_ATTUALE_FORNITORE, 
	   dm1.PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, dm1.DATA_ULTIMO_CONTRATTO, dm1.UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, dm1.VALORE_COMPLESSIVO_OFFERTA, 
	   dm1.NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, dm1.NOTE_OPERATORE_ECONOMICO, dm1.ONERI_SICUREZZA, dm1.PARTITA_IVA_DEPOSITARIO, dm1.RAGIONE_SOCIALE_DEPOSITARIO, 
	   dm1.IDENTIFICATIVO_OGGETTO_INIZIATIVA, dm1.AREA_MERCEOLOGICA, dm1.PERC_SCONTO_FISSATA_PER_LEGGE, dm1.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, 
	   dm1.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, dm1.ADESIONE_PAYBACK, dm1.DescrizioneAIC, dm1.ValoreAccessorioTecnico, dm1.TipoAcquisto, dm1.Subordinato, 
	   dm1.ArticoliPrimari, dm1.SelRow, dm1.Erosione, dm1.ValoreSconto, dm1.ValoreRibasso, dm1.PunteggioTecnicoAssegnato, dm1.PunteggioTecnicoRiparCriterio, 
	   dm1.PunteggioTecnicoRiparTotale, dm1.Campo_Intero_1, dm1.Campo_Intero_2, dm1.Campo_Intero_3, dm1.Campo_Intero_4, dm1.Campo_Intero_5, dm1.CODICE_CIVAB, 
	   dm1.DESCRIZIONE_CIVAB, dm1.CODICE_EAN, dm1.CODICE_FISCALE_OPERATORE_ECONOMICO, dm1.CODICE_FISCALE_PRODUTTORE, dm1.CODICE_PARAF, dm1.TIPO_REPERTORIO
	   ,dm1.CampoAllegato_6,dm1.CampoAllegato_7,dm1.CampoAllegato_8,dm1.CampoAllegato_9,dm1.CampoAllegato_10,dm1.ONERI_SICUREZZA_NR,dm1.TIPOLOGIA_FORNITURA,dm1.CampoTesto_11,
	   dm1.CampoTesto_12,dm1.CampoTesto_13,dm1.CampoTesto_14,dm1.CampoTesto_15,dm1.CampoTesto_16,dm1.CampoTesto_17,dm1.CampoTesto_18,dm1.CampoTesto_19,dm1.CampoTesto_20,
	   dm1.CampoNumerico_11,dm1.CampoNumerico_12,dm1.CampoNumerico_13,dm1.CampoNumerico_14,dm1.CampoNumerico_15,dm1.CampoNumerico_16,dm1.CampoNumerico_17,dm1.CampoNumerico_18
	   ,dm1.CampoNumerico_19,dm1.CampoNumerico_20,dm1.CampoAllegato_11,dm1.CampoAllegato_12,dm1.CampoAllegato_13,dm1.CampoAllegato_14,dm1.CampoAllegato_15,dm1.CampoAllegato_16,
	   dm1.CampoAllegato_17,dm1.CampoAllegato_18,dm1.CampoAllegato_19,dm1.CampoAllegato_20,dm1.Campo_Intero_6,dm1.Campo_Intero_7,dm1.Campo_Intero_8,dm1.Campo_Intero_9,
	   dm1.Campo_Intero_10,dm1.Campo_Intero_11,dm1.Campo_Intero_12,dm1.Campo_Intero_13,dm1.Campo_Intero_14,dm1.Campo_Intero_15,dm1.Campo_Intero_16,
	   dm1.Campo_Intero_17,dm1.Campo_Intero_18,dm1.Campo_Intero_19,dm1.Campo_Intero_20	
	   ,cast(DM.NoteLotto as nvarchar(MAX)) as NoteLotto
from 
	Document_MicroLotti_Dettagli DM with (nolock)
		left join Document_MicroLotti_Dettagli DM1 with (nolock) on DM.id=DM1.idheader and DM1.tipodoc='ANALISI_FABBISOGNO_DETTAGLIO'
		inner join aziende a with (nolock) on dM1.Aggiudicata = a.IdAzi
	where DM.tipodoc='ANALISI_FABBISOGNI' 







GO
