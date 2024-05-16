USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SEDUTA_VIRTUALE_OFFERTA_BUSTA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_SEDUTA_VIRTUALE_OFFERTA_BUSTA_VIEW] as 
	   --TUTTE LE COLONNE DI TIPO ALLEGATO LE SETTO A NULL
	   --SUL DOC DOVE USATA NON DEVONO ARRIVARE AL CLIENT GLI ALLEGATI
		select 
			s.id as idLottoOfferto
			,D.Id
			,D.IdHeader
			,D.TipoDoc
			,D.Graduatoria
			,D.Sorteggio
			,D.Posizione
			,D.Aggiudicata
			,D.Exequo
			,D.StatoRiga
			,D.EsitoRiga
			,D.ValoreOfferta
			,D.NumeroLotto
			,D.Descrizione
			,D.Qty
			,D.PrezzoUnitario
			,D.CauzioneMicrolotto
			,D.CIG
			,D.CodiceATC
			,D.PrincipioAttivo
			,D.FormaFarmaceutica
			,D.Dosaggio
			,D.Somministrazione
			,D.UnitadiMisura
			,D.Quantita
			,D.ImportoBaseAstaUnitaria
			,D.ImportoAnnuoLotto
			,D.ImportoTriennaleLotto
			,D.NoteLotto
			,D.CodiceAIC
			,D.QuantitaConfezione
			,D.ClasseRimborsoMedicinale
			,D.PrezzoVenditaConfezione
			,D.AliquotaIva
			,D.ScontoUlteriore
			,D.EstremiGURI
			,D.PrezzoUnitarioOfferta
			,D.PrezzoUnitarioRiferimento
			,D.TotaleOffertaUnitario
			,D.ScorporoIVA
			,D.PrezzoVenditaConfezioneIvaEsclusa
			,D.PrezzoVenditaUnitario
			,D.ScontoOffertoUnitario
			,D.ScontoObbligatorioUnitario
			,D.DenominazioneProdotto
			,D.RagSocProduttore
			,D.CodiceProdotto
			,D.MarcaturaCE
			,D.NumeroRepertorio
			,D.NumeroCampioni
			,D.Versamento
			,D.PrezzoInLettere
			,D.importoBaseAsta
			,D.CampoTesto_1
			,D.CampoTesto_2
			,D.CampoTesto_3
			,D.CampoTesto_4
			,D.CampoTesto_5
			,D.CampoTesto_6
			,D.CampoTesto_7
			,D.CampoTesto_8
			,D.CampoTesto_9
			,D.CampoTesto_10
			,D.CampoNumerico_1
			,D.CampoNumerico_2
			,D.CampoNumerico_3
			,D.CampoNumerico_4
			,D.CampoNumerico_5
			,D.CampoNumerico_6
			,D.CampoNumerico_7
			,D.CampoNumerico_8
			,D.CampoNumerico_9
			,D.CampoNumerico_10
			,D.Voce
			,D.idHeaderLotto
			,NULL AS CampoAllegato_1
			,NULL AS CampoAllegato_2
			,NULL AS CampoAllegato_3
			,NULL AS CampoAllegato_4
			,NULL AS CampoAllegato_5
			,D.NumeroRiga
			,D.PunteggioTecnico
			,D.ValoreEconomico
			,D.PesoVoce
			,D.ValoreImportoLotto
			,D.Variante
			,D.CONTRATTO
			,D.CODICE_AZIENDA_SANITARIA
			,D.CODICE_REGIONALE
			,D.DESCRIZIONE_CODICE_REGIONALE
			,D.TARGET
			,D.MATERIALE
			,D.LATEX_FREE
			,D.MISURE
			,D.VOLUME
			,D.ALTRE_CARATTERISTICHE
			,D.CONFEZIONAMENTO_PRIMARIO
			,D.PESO_CONFEZIONE
			,D.DIMENSIONI_CONFEZIONE
			,D.TEMPERATURA_CONSERVAZIONE
			,D.QUANTITA_PRODOTTO_SINGOLO_PEZZO
			,D.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO
			,D.UM_DOSAGGIO
			,D.PARTITA_IVA_FORNITORE
			,D.RAGIONE_SOCIALE_FORNITORE
			,D.CODICE_ARTICOLO_FORNITORE
			,D.DENOMINAZIONE_ARTICOLO_FORNITORE
			,D.DATA_INIZIO_PERIODO_VALIDITA
			,D.DATA_FINE_PERIODO_VALIDITA
			,D.RIFERIMENTO_TEMPORALE_FABBISOGNO
			,D.FABBISOGNO_PREVISTO
			,D.PREZZO_OFFERTO_PER_UM
			,D.CONTENUTO_DI_UM_CONFEZIONE
			,D.PREZZO_CONFEZIONE_IVA_ESCLUSA
			,D.PREZZO_PEZZO
			,D.SCHEDA_PRODOTTO
			,D.CODICE_CND
			,D.DESCRIZIONE_CND
			,D.CODICE_CPV
			,D.DESCRIZIONE_CODICE_CPV
			,D.LIVELLO
			,D.CERTIFICAZIONI
			,D.CARATTERISTICHE_SOCIALI_AMBIENTALI
			,D.PREZZO_BASE_ASTA_UM_IVA_ESCLUSA
			,D.VALORE_BASE_ASTA_IVA_ESCLUSA
			,D.RAGIONE_SOCIALE_ATTUALE_FORNITORE
			,D.PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE
			,D.DATA_ULTIMO_CONTRATTO
			,D.UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE
			,D.VALORE_COMPLESSIVO_OFFERTA
			,D.NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI
			,D.NOTE_OPERATORE_ECONOMICO
			,D.ONERI_SICUREZZA
			,D.PARTITA_IVA_DEPOSITARIO
			,D.RAGIONE_SOCIALE_DEPOSITARIO
			,D.IDENTIFICATIVO_OGGETTO_INIZIATIVA
			,D.AREA_MERCEOLOGICA
			,D.PERC_SCONTO_FISSATA_PER_LEGGE
			,D.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1
			,D.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2
			,D.ADESIONE_PAYBACK
			,D.DescrizioneAIC
			,D.ValoreAccessorioTecnico
			,D.TipoAcquisto
			,D.Subordinato
			,D.ArticoliPrimari
			,D.SelRow
			,D.Erosione
			,D.ValoreSconto
			,D.ValoreRibasso
			,D.PunteggioTecnicoAssegnato
			,D.PunteggioTecnicoRiparCriterio
			,D.PunteggioTecnicoRiparTotale
			,D.Campo_Intero_1
			,D.Campo_Intero_2
			,D.Campo_Intero_3
			,D.Campo_Intero_4
			,D.Campo_Intero_5
			,D.CODICE_CIVAB
			,D.DESCRIZIONE_CIVAB
			,D.CODICE_EAN
			,D.CODICE_FISCALE_OPERATORE_ECONOMICO
			,D.CODICE_FISCALE_PRODUTTORE
			,D.CODICE_PARAF
			,D.TIPO_REPERTORIO
			,NULL AS CampoAllegato_6
			,NULL AS CampoAllegato_7
			,NULL AS CampoAllegato_8
			,NULL AS CampoAllegato_9
			,NULL AS CampoAllegato_10
			,D.ONERI_SICUREZZA_NR
			,D.TIPOLOGIA_FORNITURA
			,D.CampoTesto_11
			,D.CampoTesto_12
			,D.CampoTesto_13
			,D.CampoTesto_14
			,D.CampoTesto_15
			,D.CampoTesto_16
			,D.CampoTesto_17
			,D.CampoTesto_18
			,D.CampoTesto_19
			,D.CampoTesto_20
			,D.CampoNumerico_11
			,D.CampoNumerico_12
			,D.CampoNumerico_13
			,D.CampoNumerico_14
			,D.CampoNumerico_15
			,D.CampoNumerico_16
			,D.CampoNumerico_17
			,D.CampoNumerico_18
			,D.CampoNumerico_19
			,D.CampoNumerico_20
			,NULL AS CampoAllegato_11
			,NULL AS CampoAllegato_12
			,NULL AS CampoAllegato_13
			,NULL AS CampoAllegato_14
			,NULL AS CampoAllegato_15
			,NULL AS CampoAllegato_16
			,NULL AS CampoAllegato_17
			,NULL AS CampoAllegato_18
			,NULL AS CampoAllegato_19
			,NULL AS CampoAllegato_20
			,D.Campo_Intero_6
			,D.Campo_Intero_7
			,D.Campo_Intero_8
			,D.Campo_Intero_9
			,D.Campo_Intero_10
			,D.Campo_Intero_11
			,D.Campo_Intero_12
			,D.Campo_Intero_13
			,D.Campo_Intero_14
			,D.Campo_Intero_15
			,D.Campo_Intero_16
			,D.Campo_Intero_17
			,D.Campo_Intero_18
			,D.Campo_Intero_19
			,D.Campo_Intero_20
			,D.PrezzoVenditaConfezioneIvaInclusa
			,D.STERILE
			,D.MONOUSO
			,D.QT_NUM_PRODOTTO_SINGOLO_PEZZO
			,D.PEZZI_PER_CONFEZIONE
			,D.COSTI_MANODOPERA
			,D.PercAgg
			,D.Dominio_SiNo
			,D.Intervallo_0_24
			,D.Dominio_SiNo_2
			,D.Dominio_SiNo_3
			,D.CODIFICA_ARTICOLO_OE_PEZZO_SINGOLO
			,D.PERC_RIBASSO
			,D.Temperatura_minima_di_conservazione
			,D.Temperatura_massima_di_conservazione
			,D.Ftalati_free
			,D.Infiammabile
			,D.[Presenza_medicinali]
			,D.Sostanza_corrosiva
			,D.Sostanza_tossica
			,D.Sostanza_velenosa
			,D.Classe_di_Rimborsabilita
			,D.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA3,
			d.[CODICE_ISO], 
			d.[CODICE_REF], 
			d.[COMODATO_DUSO], 
			d.[CONFEZIONAMENTO_SECONDARIO_ECOCOMPATIBILE], 
			d.[CONTENUTO_DI_UP_PER_CONFEZIONE], 
			d.[DEFINED_DAILY_DOSE], 
			d.[DENOMINAZIONE_ARTICOLO_COMPLETA], 
			d.[DENOMINAZIONE_ARTICOLO_SINTETICA], 
			d.[DENOMINAZIONE_COMMERCIALE], 
			d.[DESCRIZIONE_COMPLETA_PARAF_BDF], 
			d.[DOSAGGIO_QTA_PER_PRINCIPIO_ATTIVO], 
			d.[FARMACO_ESCLUSIVO], 
			d.[FATTORE_PRODUTTIVO], 
			d.[INCLUSIONE_PHT], 
			d.[NUMERO_UNITA_POSOLOGICA_CONTENUTA_INT_BANCALE], 
			d.[PREZZO_AL_PUBBLICO_PER_CONFEZIONEivainclusa], 
			d.[SCADENZA_BREVETTO], 
			d.[SCHEDA_DI_SICUREZZA], 
			d.[SCHEDA_TECNICA_PRODOTTO], 
			d.[VALORE_UNITARIO_OFFERTO_IVA_ESCLUSA]
			from document_microlotti_dettagli S with(nolock)
				inner join document_microlotti_dettagli D with(nolock) on D.idheader = S.idheader and D.tipodoc = 'PDA_OFFERTE'  and s.NumeroLotto = d.NumeroLotto 


GO
