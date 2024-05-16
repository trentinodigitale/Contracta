USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_GARA_RIEPILOGO_LOTTO_LISTA_OFFERTE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_GARA_RIEPILOGO_LOTTO_LISTA_OFFERTE] as
	select 	  m.id as IdRowLottoBando 
			, o.aziRagioneSociale
			, isnull(od.Id,m.Id) as Id, od.IdHeader, od.TipoDoc, od.Graduatoria, isnull(od.Sorteggio,0) as Sorteggio, od.Posizione, od.Aggiudicata, od.Exequo, od.StatoRiga, od.EsitoRiga, od.ValoreOfferta, od.NumeroLotto, od.Descrizione, od.Qty, od.PrezzoUnitario, od.CauzioneMicrolotto, od.CIG, od.CodiceATC, od.PrincipioAttivo, od.FormaFarmaceutica, od.Dosaggio, od.Somministrazione, od.UnitadiMisura, od.Quantita, od.ImportoBaseAstaUnitaria, od.ImportoAnnuoLotto, od.ImportoTriennaleLotto, od.NoteLotto, od.CodiceAIC, od.QuantitaConfezione, od.ClasseRimborsoMedicinale, od.PrezzoVenditaConfezione, od.AliquotaIva, od.ScontoUlteriore, od.EstremiGURI, od.PrezzoUnitarioOfferta, od.PrezzoUnitarioRiferimento, od.TotaleOffertaUnitario, od.ScorporoIVA, od.PrezzoVenditaConfezioneIvaEsclusa, od.PrezzoVenditaUnitario, od.ScontoOffertoUnitario, od.ScontoObbligatorioUnitario, od.DenominazioneProdotto, od.RagSocProduttore, od.CodiceProdotto, od.MarcaturaCE, od.NumeroRepertorio, od.NumeroCampioni, od.Versamento, od.PrezzoInLettere, od.importoBaseAsta, od.CampoTesto_1, od.CampoTesto_2, od.CampoTesto_3, od.CampoTesto_4, od.CampoTesto_5, od.CampoTesto_6, od.CampoTesto_7, od.CampoTesto_8, od.CampoTesto_9, od.CampoTesto_10, od.CampoNumerico_1, od.CampoNumerico_2, od.CampoNumerico_3, od.CampoNumerico_4, od.CampoNumerico_5, od.CampoNumerico_6, od.CampoNumerico_7, od.CampoNumerico_8, od.CampoNumerico_9, od.CampoNumerico_10, isnull(od.Voce,0) as Voce, od.idHeaderLotto, od.CampoAllegato_1, od.CampoAllegato_2, od.CampoAllegato_3, od.CampoAllegato_4, od.CampoAllegato_5, od.NumeroRiga, od.PunteggioTecnico, od.ValoreEconomico, od.PesoVoce, od.ValoreImportoLotto, od.Variante, od.CONTRATTO, od.CODICE_AZIENDA_SANITARIA, od.CODICE_REGIONALE, od.DESCRIZIONE_CODICE_REGIONALE, od.TARGET, od.MATERIALE, od.LATEX_FREE, od.MISURE, od.VOLUME, od.ALTRE_CARATTERISTICHE, od.CONFEZIONAMENTO_PRIMARIO, od.PESO_CONFEZIONE, od.DIMENSIONI_CONFEZIONE, od.TEMPERATURA_CONSERVAZIONE, od.QUANTITA_PRODOTTO_SINGOLO_PEZZO, od.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, od.UM_DOSAGGIO, od.PARTITA_IVA_FORNITORE, od.RAGIONE_SOCIALE_FORNITORE, od.CODICE_ARTICOLO_FORNITORE, od.DENOMINAZIONE_ARTICOLO_FORNITORE, od.DATA_INIZIO_PERIODO_VALIDITA, od.DATA_FINE_PERIODO_VALIDITA, od.RIFERIMENTO_TEMPORALE_FABBISOGNO, od.FABBISOGNO_PREVISTO, od.PREZZO_OFFERTO_PER_UM, od.CONTENUTO_DI_UM_CONFEZIONE, od.PREZZO_CONFEZIONE_IVA_ESCLUSA, od.PREZZO_PEZZO, od.SCHEDA_PRODOTTO, od.CODICE_CND, od.DESCRIZIONE_CND, od.CODICE_CPV, od.DESCRIZIONE_CODICE_CPV, od.LIVELLO, od.CERTIFICAZIONI, od.CARATTERISTICHE_SOCIALI_AMBIENTALI, od.PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, od.VALORE_BASE_ASTA_IVA_ESCLUSA, od.RAGIONE_SOCIALE_ATTUALE_FORNITORE, od.PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, od.DATA_ULTIMO_CONTRATTO, od.UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, od.VALORE_COMPLESSIVO_OFFERTA, od.NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, od.NOTE_OPERATORE_ECONOMICO, od.ONERI_SICUREZZA, od.PARTITA_IVA_DEPOSITARIO, od.RAGIONE_SOCIALE_DEPOSITARIO, od.IDENTIFICATIVO_OGGETTO_INIZIATIVA, od.AREA_MERCEOLOGICA, od.PERC_SCONTO_FISSATA_PER_LEGGE, od.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1, od.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2, od.ADESIONE_PAYBACK, od.DescrizioneAIC, od.ValoreAccessorioTecnico, od.TipoAcquisto, od.Subordinato, od.ArticoliPrimari, od.SelRow, od.Erosione, od.ValoreSconto, od.ValoreRibasso, od.PunteggioTecnicoAssegnato, od.PunteggioTecnicoRiparCriterio, od.PunteggioTecnicoRiparTotale, od.Campo_Intero_1, od.Campo_Intero_2, od.Campo_Intero_3, od.Campo_Intero_4, od.Campo_Intero_5, od.CODICE_CIVAB, od.DESCRIZIONE_CIVAB, od.CODICE_EAN, od.CODICE_FISCALE_OPERATORE_ECONOMICO, od.CODICE_FISCALE_PRODUTTORE, od.CODICE_PARAF, od.TIPO_REPERTORIO, od.CampoAllegato_6, od.CampoAllegato_7, od.CampoAllegato_8, od.CampoAllegato_9, od.CampoAllegato_10, od.ONERI_SICUREZZA_NR, od.TIPOLOGIA_FORNITURA, od.CampoTesto_11, od.CampoTesto_12, od.CampoTesto_13, od.CampoTesto_14, od.CampoTesto_15, od.CampoTesto_16, od.CampoTesto_17, od.CampoTesto_18, od.CampoTesto_19, od.CampoTesto_20, od.CampoNumerico_11, od.CampoNumerico_12, od.CampoNumerico_13, od.CampoNumerico_14, od.CampoNumerico_15, od.CampoNumerico_16, od.CampoNumerico_17, od.CampoNumerico_18, od.CampoNumerico_19, od.CampoNumerico_20, od.CampoAllegato_11, od.CampoAllegato_12, od.CampoAllegato_13, od.CampoAllegato_14, od.CampoAllegato_15, od.CampoAllegato_16, od.CampoAllegato_17, od.CampoAllegato_18, od.CampoAllegato_19, od.CampoAllegato_20, od.Campo_Intero_6, od.Campo_Intero_7, od.Campo_Intero_8, od.Campo_Intero_9, od.Campo_Intero_10, od.Campo_Intero_11, od.Campo_Intero_12, od.Campo_Intero_13, od.Campo_Intero_14, od.Campo_Intero_15, od.Campo_Intero_16, od.Campo_Intero_17, od.Campo_Intero_18, od.Campo_Intero_19, od.Campo_Intero_20, od.PrezzoVenditaConfezioneIvaInclusa, od.STERILE, od.MONOUSO, od.QT_NUM_PRODOTTO_SINGOLO_PEZZO, od.PEZZI_PER_CONFEZIONE, od.COSTI_MANODOPERA
			, case when isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) < 0 then null else isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) end as PunteggioEconomico
			, od.id as IdOffertaLotto	
			, case when od.Id is null then 'Esclusa in fase amministrativa' else dbo.PDA_MICROLOTTI_ListaMotivazioni_LOTTO( od.id , 'ECONOMICA' ) end as Motivazione
			, o.idMsg 
			, o.TipoDoc as OPEN_DOC_NAME
			, d.id as idPDA
			, cast( isnull(NumRiga,'0') as int ) as NumRiga
			, a.aziPartitaIVA
			, a.aziLocalitaLeg
			, a.aziE_Mail
		from CTL_DOC d with(nolock)
			inner join Document_MicroLotti_Dettagli m with(nolock) on d.id = m.IdHeader and  m.tipoDoc = 'PDA_MICROLOTTI' --i lotti nella pda
			--inner join Document_Bando ba on d.LinkedDoc = ba.idHeader
			inner join Document_PDA_OFFERTE o with(nolock) on d.id =  o.idheader
			left outer join aziende a with(nolock) on a.idazi = o.idAziPartecipante
			
			left join Document_MicroLotti_Dettagli od with(nolock) on od.idHeader = o.idRow  and od.tipoDoc = 'PDA_OFFERTE' and isnull(od.NumeroLotto, '1') = m.NumeroLotto and od.voce = 0

		where deleted = 0	and m.voce = 0 



GO
