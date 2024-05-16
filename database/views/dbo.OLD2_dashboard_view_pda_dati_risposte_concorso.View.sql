USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_dashboard_view_pda_dati_risposte_concorso]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[OLD2_dashboard_view_pda_dati_risposte_concorso]
AS
	SELECT   
			  o.IdHeader AS idPDA ,
			  o.Idmsg,

			  R.Titolo as Progressivo_Risposta,

			  case 
				when isnull(IA.value,0) = 0 then ''
				else o.aziRagionesociale 
			  end as aziRagionesociale,

			  case 
				when isnull(IA.value,0) = 0 then ''
				else a.vatValore_FT
			  end as codicefiscale,

			  case 
				when isnull(IA.value,0) = 0 then ''
				else o.ProtocolloOfferta
			  end as ProtocolloOfferta,

			  BC.importoBaseAsta,
			  
			  B.body as Descrizione,

			  d.Id ,
			  --d.IdHeader ,
			 -- d.TipoDoc ,
			  cast( d.NumeroLotto as int ) as NumeroLotto,
			  d.Graduatoria ,
			  d.Sorteggio ,
			  case when K.StatoRiga='Revocato' then 'Revocato' else  d.Posizione end as Posizione,
			  d.Aggiudicata ,
			  d.Exequo ,
			  d.StatoRiga ,
			  d.EsitoRiga ,
			  d.ValoreOfferta ,
			  d.ValoreImportoLotto ,
			  d.ValoreSconto ,
			  d.ValoreRibasso ,
			  d.PunteggioTecnicoAssegnato ,
			  d.PunteggioTecnicoRiparCriterio ,
			  d.PunteggioTecnicoRiparTotale ,
			  
			  d1.CampoAllegato_1 ,
			  d1.CampoAllegato_2 ,
			  d1.CampoAllegato_3 ,
			  d1.CampoAllegato_4 ,
			  d1.CampoAllegato_5 ,
			  d1.CampoAllegato_6 ,
			  d1.CampoAllegato_7 ,
			  d1.CampoAllegato_8 ,
			  d1.CampoAllegato_9 ,
			  d1.CampoAllegato_10 ,
			  d1.CampoAllegato_11 , 
			  d1.CampoAllegato_12 , 
			  d1.CampoAllegato_13 , 
			  d1.CampoAllegato_14 , 
			  d1.CampoAllegato_15 , 
			  d1.CampoAllegato_16 , 
			  d1.CampoAllegato_17 , 
			  d1.CampoAllegato_18 , 
			  d1.CampoAllegato_19 , 
			  d1.CampoAllegato_20 
			  
		FROM  
		
			document_pda_offerte o with(nolock)
				
				inner join ctl_doc PDA_C with(nolock) on PDA_C.id = O.IdHeader

				inner join ctl_doc B with(nolock) on B.id = PDA_C.LinkedDoc

				inner join document_bando BC with(nolock) on BC.idheader = B.id

				inner join ctl_doc R with(nolock) on R.id = O.IdMsg

				inner JOIN document_microlotti_dettagli d with(nolock) ON d.idheader = o.idrow AND d.tipodoc = 'PDA_OFFERTE' and voce=0 and numerolotto = 1--and t.NumeroLotto = d.NumeroLotto 
				
				inner JOIN document_microlotti_dettagli d1 with(nolock) ON d1.idheader = o.idrow AND d1.tipodoc = 'PDA_OFFERTE' and d1.NumeroLotto = 1 and d1.voce is null

				INNER JOIN dm_attributi a with(nolock) ON a.lnk = o.idAziPartecipante AND dztnome = 'CodiceFiscale' and idApp=1
			
				left outer join (  select o.NumeroLotto , d.idheader ,max(o.StatoRiga) as StatoRiga
											from Document_PDA_OFFERTE d with(nolock) 
												inner join Document_MicroLotti_Dettagli o with(nolock) on d.IdHeader = o.idheader and o.TipoDoc = 'PDA_MICROLOTTI'
												where o.voce = 0
											group by o.NumeroLotto , d.idheader 

									) as K on K.IdHeader = o.IdHeader and k.NumeroLotto = 1 --d.NumeroLotto

				left join ctl_doc_value IA with(nolock) ON IA.IdHeader = o.IdHeader and DSE_ID='ANONIMATO' and DZT_Name='DATI_IN_CHIARO'
		WHERE 
			o.statopda IN ('2' , '22' , '222' , '9' )
			and ISNULL(k.NumeroLotto,'') = ISNULL(d.NumeroLotto,'')

-- tutti i lotti deserti
--union all

--	SELECT    C.ID  AS idPDA ,
--			  0 as Idmsg,
--			  '' AS aziRagionesociale ,
--			  '' AS codicefiscale ,
--			  '' AS ProtocolloOfferta , 
--			  --graduatoria ,
--			  --Statoriga , 
--			  --[Posizione] ,

			
--			  t.Id ,
--			  t.IdHeader ,
--			  t.TipoDoc ,

--			  t.Graduatoria ,
--			  t.Sorteggio ,
--			  t.Posizione ,
--			  t.Aggiudicata ,
--			  t.Exequo ,
--			  'Deserta' as StatoRiga ,
--			  t.EsitoRiga ,
--			  t.ValoreOfferta ,
--			  t.ValoreImportoLotto ,
--			  t.ValoreSconto ,
--			  t.ValoreRibasso ,
--			  t.PunteggioTecnicoAssegnato ,
--			  t.PunteggioTecnicoRiparCriterio ,
--			  t.PunteggioTecnicoRiparTotale ,


--			  cast( t.NumeroLotto as int ) as NumeroLotto,
--			  t.Descrizione ,
--			  t.Qty ,
--			  t.PrezzoUnitario ,
--			  t.CauzioneMicrolotto ,
--			  t.CIG ,
--			  t.CodiceATC ,
--			  t.PrincipioAttivo ,
--			  t.FormaFarmaceutica ,
--			  t.Dosaggio ,
--			  t.Somministrazione ,
--			  t.UnitadiMisura ,
--			  t.Quantita ,
--			  t.ImportoBaseAstaUnitaria ,
--			  t.ImportoAnnuoLotto ,
--			  t.ImportoTriennaleLotto ,
--			  t.NoteLotto ,
--			  t.CodiceAIC ,
--			  t.QuantitaConfezione ,
--			  t.ClasseRimborsoMedicinale ,
--			  t.PrezzoVenditaConfezione ,
--			  t.AliquotaIva ,
--			  t.ScontoUlteriore ,
--			  t.EstremiGURI ,
--			  t.PrezzoUnitarioOfferta ,
--			  t.PrezzoUnitarioRiferimento ,
--			  t.TotaleOffertaUnitario ,
--			  t.ScorporoIVA ,
--			  t.PrezzoVenditaConfezioneIvaEsclusa ,
--			  t.PrezzoVenditaUnitario ,
--			  t.ScontoOffertoUnitario ,
--			  t.ScontoObbligatorioUnitario ,
--			  t.DenominazioneProdotto ,
--			  t.RagSocProduttore ,
--			  t.CodiceProdotto ,
--			  t.MarcaturaCE ,
--			  t.NumeroRepertorio ,
--			  t.NumeroCampioni ,
--			  t.Versamento ,
--			  t.PrezzoInLettere ,
--			  t.importoBaseAsta ,
--			  t.CampoTesto_1 ,
--			  t.CampoTesto_2 ,
--			  t.CampoTesto_3 ,
--			  t.CampoTesto_4 ,
--			  t.CampoTesto_5 ,
--			  t.CampoTesto_6 ,
--			  t.CampoTesto_7 ,
--			  t.CampoTesto_8 ,
--			  t.CampoTesto_9 ,
--			  t.CampoTesto_10 ,
--			  t.CampoNumerico_1 ,
--			  t.CampoNumerico_2 ,
--			  t.CampoNumerico_3 ,
--			  t.CampoNumerico_4 ,
--			  t.CampoNumerico_5 ,
--			  t.CampoNumerico_6 ,
--			  t.CampoNumerico_7 ,
--			  t.CampoNumerico_8 ,
--			  t.CampoNumerico_9 ,
--			  t.CampoNumerico_10 ,
--			  t.Voce ,
--			  t.idHeaderLotto ,
--			  t.CampoAllegato_1 ,
--			  t.CampoAllegato_2 ,
--			  t.CampoAllegato_3 ,
--			  t.CampoAllegato_4 ,
--			  t.CampoAllegato_5 ,
--			  t.NumeroRiga ,
--			  t.PunteggioTecnico ,
--			  t.ValoreEconomico ,
--			  t.PesoVoce ,
--			  t.Variante ,
--			  t.CONTRATTO ,
--			  t.CODICE_AZIENDA_SANITARIA ,
--			  t.CODICE_REGIONALE ,
--			  t.DESCRIZIONE_CODICE_REGIONALE ,
--			  t.TARGET ,
--			  t.MATERIALE ,
--			  t.LATEX_FREE ,
--			  t.MISURE ,
--			  t.VOLUME ,
--			  t.ALTRE_CARATTERISTICHE ,
--			  t.CONFEZIONAMENTO_PRIMARIO ,
--			  t.PESO_CONFEZIONE ,
--			  t.DIMENSIONI_CONFEZIONE ,
--			  t.TEMPERATURA_CONSERVAZIONE ,
--			  t.QUANTITA_PRODOTTO_SINGOLO_PEZZO ,
--			  t.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO ,
--			  t.UM_DOSAGGIO ,
--			  t.PARTITA_IVA_FORNITORE ,
--			  t.RAGIONE_SOCIALE_FORNITORE ,
--			  t.CODICE_ARTICOLO_FORNITORE ,
--			  t.DENOMINAZIONE_ARTICOLO_FORNITORE ,
--			  t.DATA_INIZIO_PERIODO_VALIDITA ,
--			  t.DATA_FINE_PERIODO_VALIDITA ,
--			  t.RIFERIMENTO_TEMPORALE_FABBISOGNO ,
--			  t.FABBISOGNO_PREVISTO ,
--			  t.PREZZO_OFFERTO_PER_UM ,
--			  t.CONTENUTO_DI_UM_CONFEZIONE ,
--			  t.PREZZO_CONFEZIONE_IVA_ESCLUSA ,
--			  t.PREZZO_PEZZO ,
--			  t.SCHEDA_PRODOTTO ,
--			  t.CODICE_CND ,
--			  t.DESCRIZIONE_CND ,
--			  t.CODICE_CPV ,
--			  t.DESCRIZIONE_CODICE_CPV ,
--			  t.LIVELLO ,
--			  t.CERTIFICAZIONI ,
--			  t.CARATTERISTICHE_SOCIALI_AMBIENTALI ,
--			  t.PREZZO_BASE_ASTA_UM_IVA_ESCLUSA ,
--			  t.VALORE_BASE_ASTA_IVA_ESCLUSA ,
--			  t.RAGIONE_SOCIALE_ATTUALE_FORNITORE ,
--			  t.PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE ,
--			  t.DATA_ULTIMO_CONTRATTO ,
--			  t.UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE ,
--			  t.VALORE_COMPLESSIVO_OFFERTA ,
--			  t.NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI ,
--			  t.NOTE_OPERATORE_ECONOMICO ,
--			  t.ONERI_SICUREZZA ,
--			  t.PARTITA_IVA_DEPOSITARIO ,
--			  t.RAGIONE_SOCIALE_DEPOSITARIO ,
--			  t.IDENTIFICATIVO_OGGETTO_INIZIATIVA ,
--			  t.AREA_MERCEOLOGICA ,
--			  t.PERC_SCONTO_FISSATA_PER_LEGGE ,
--			  t.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1 ,
--			  t.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2 ,
--			  t.ADESIONE_PAYBACK ,
--			  t.DescrizioneAIC ,
--			  t.ValoreAccessorioTecnico ,
--			  t.TipoAcquisto ,
--			  t.Subordinato ,
--			  t.ArticoliPrimari ,
--			  t.SelRow ,
--			  t.Erosione ,
--			  t.Campo_Intero_1 ,
--			  t.Campo_Intero_2 ,
--			  t.Campo_Intero_3 ,
--			  t.Campo_Intero_4 ,
--			  t.Campo_Intero_5 ,
--			  t.CODICE_CIVAB ,
--			  t.DESCRIZIONE_CIVAB ,
--			  t.CODICE_EAN ,
--			  t.CODICE_FISCALE_OPERATORE_ECONOMICO ,
--			  t.CODICE_FISCALE_PRODUTTORE ,
--			  t.CODICE_PARAF ,
--			  t.TIPO_REPERTORIO ,
--			  t.CampoAllegato_6 ,
--			  t.CampoAllegato_7 ,
--			  t.CampoAllegato_8 ,
--			  t.CampoAllegato_9 ,
--			  t.CampoAllegato_10 ,
--			  t.ONERI_SICUREZZA_NR ,
--			  t.TIPOLOGIA_FORNITURA ,
--			  t.CampoTesto_11 ,
--			  t.CampoTesto_12 ,
--			  t.CampoTesto_13 ,
--			  t.CampoTesto_14 ,
--			  t.CampoTesto_15 ,
--			  t.CampoTesto_16 ,
--			  t.CampoTesto_17 ,
--			  t.CampoTesto_18 ,
--			  t.CampoTesto_19 ,
--			  t.CampoTesto_20 ,
--			  t.CampoNumerico_11 ,
--			  t.CampoNumerico_12 ,
--			  t.CampoNumerico_13 ,
--			  t.CampoNumerico_14 ,
--			  t.CampoNumerico_15 ,
--			  t.CampoNumerico_16 ,
--			  t.CampoNumerico_17 ,
--			  t.CampoNumerico_18 ,
--			  t.CampoNumerico_19 ,
--			  t.CampoNumerico_20 ,
--			  t.CampoAllegato_11 , 
--			  t.CampoAllegato_12 , 
--			  t.CampoAllegato_13 , 
--			  t.CampoAllegato_14 , 
--			  t.CampoAllegato_15 , 
--			  t.CampoAllegato_16 , 
--			  t.CampoAllegato_17 , 
--			  t.CampoAllegato_18 , 
--			  t.CampoAllegato_19 , 
--			  t.CampoAllegato_20 , 
--			  t.Campo_Intero_6 ,
--			  t.Campo_Intero_7 ,
--			  t.Campo_Intero_8 ,
--			  t.Campo_Intero_9 ,
--			  t.Campo_Intero_10 ,
--			  t.Campo_Intero_11 ,
--			  t.Campo_Intero_12 ,
--			  t.Campo_Intero_13 ,
--			  t.Campo_Intero_14 ,
--			  t.Campo_Intero_15 ,
--			  t.Campo_Intero_16 ,
--			  t.Campo_Intero_17 ,
--			  t.Campo_Intero_18 ,
--			  t.Campo_Intero_19 ,
--			  t.Campo_Intero_20 ,
--			  t.PrezzoVenditaConfezioneIvaInclusa,
--			  t.QT_NUM_PRODOTTO_SINGOLO_PEZZO,
--			  t.PEZZI_PER_CONFEZIONE,
--			  t.STERILE,
--			  t.MONOUSO,
--			  t.COSTI_MANODOPERA,
--			  t.[PercAgg],
--			  t.[Dominio_SiNo],
--			  t.[Intervallo_0_24],
--			  t.[Dominio_SiNo_2],
--			  t.[Dominio_SiNo_3],
--			  t.[CODIFICA_ARTICOLO_OE_PEZZO_SINGOLO],
--			  t.PERC_RIBASSO,
--			  t.[Temperatura_minima_di_conservazione],
--			  t.[Temperatura_massima_di_conservazione],
--			  t.[Ftalati_free],
--			  t.[Infiammabile],
--			  t.[Presenza_medicinali],			  			  
--			  t.[Sostanza_corrosiva],
--			  t.[Sostanza_tossica],
--			  t.[Sostanza_velenosa],
--			  t.[Classe_di_Rimborsabilita],
--			  t.[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA3],
--			  t.PunteggioEconomicoAssegnato,
--			  t.Dominio_SiNo_4,
--			  t.Dominio_SiNo_5,
--			  t.Dominio_SiNo_6,
--			  t.Dominio_SiNo_7,
--			  t.Dominio_SiNo_8,
--			  t.Dominio_SiNo_9,
--			  t.Dominio_SiNo_10,
--			  t.Dominio_SiNo_11,
--			  t.Dominio_SiNo_12,
--			  t.Dominio_SiNo_13,
--			  t.Rialzo_Offerta_Unitario,
--			  t.[CODICE_ISO], 
--			  t.[CODICE_REF], 
--			  t.[COMODATO_DUSO], 
--			  t.[CONFEZIONAMENTO_SECONDARIO_ECOCOMPATIBILE], 
--			  t.[CONTENUTO_DI_UP_PER_CONFEZIONE], 
--			  t.[DEFINED_DAILY_DOSE], 
--			  t.[DENOMINAZIONE_ARTICOLO_COMPLETA], 
--			  t.[DENOMINAZIONE_ARTICOLO_SINTETICA], 
--			  t.[DENOMINAZIONE_COMMERCIALE], 
--			  t.[DESCRIZIONE_COMPLETA_PARAF_BDF], 
--			  t.[DOSAGGIO_QTA_PER_PRINCIPIO_ATTIVO], 
--			  t.[FARMACO_ESCLUSIVO], 
--			  t.[FATTORE_PRODUTTIVO], 
--			  t.[INCLUSIONE_PHT], 
--			  t.[NUMERO_UNITA_POSOLOGICA_CONTENUTA_INT_BANCALE], 
--			  t.[PREZZO_AL_PUBBLICO_PER_CONFEZIONEivainclusa], 
--			  t.[SCADENZA_BREVETTO], 
--			  t.[SCHEDA_DI_SICUREZZA], 
--			  t.[SCHEDA_TECNICA_PRODOTTO], 
--			  t.[VALORE_UNITARIO_OFFERTO_IVA_ESCLUSA],
--			  t.[IMPORTO_OPZIONI], t.[IMPORTO_ATTUAZIONE_SICUREZZA], t.[PROGRESSIVO_RIGA], t.[DATA_CONSEGNA], t.[CODICE_WBS], t.[DESCRIZIONE_WBS], 
--			  t.[DICHIARAZIONE_LATEX_GLUTEN_LACTOS_FREE], t.[PRODOTTO_IN_ESCLUSIVA], t.[ELENCO_AIC_DISPONIBILI], t.[PRESENZA_DI_GLUTINE], 
--			  t.[PRESENZA_DI_LATTOSIO], t.[ALL_FIELD], t.[ClasseIscriz_S], t.[AREA_DI_CONSEGNA], t.[FotoProdotto], t.[IdRigaRiferimento], t.[MULTIPLI_ORDINABILI], 
--			  t.[TAGLIA],t.[MODALITA_DI_CONSERVAZIONE], t.[CODICE_DM_PMC], t.[SCHEDA_TECNICA_LINK], t.[CODICE_BDR]
--		FROM  ctl_doc c with(nolock)
			
--			inner JOIN document_microlotti_dettagli t with(nolock) ON t.idheader = C.ID AND t.tipodoc = 'PDA_MICROLOTTI' --AND t.Voce = 0 

--			LEFT OUTER JOIN ( select o.idheader , d.numerolotto from Document_PDA_OFFERTE  o with(nolock) inner join document_microlotti_dettagli d with(nolock) ON d.idheader = o.idrow AND d.tipodoc = 'PDA_OFFERTE' and d.Voce = 0 ) as d ON C.ID = d.IDHEADER and d.NumeroLotto = t.numerolotto

--			--LEFT OUTER JOIN Document_PDA_OFFERTE  o ON C.ID = O.IDHEADER
			
--			--LEFT JOIN document_microlotti_dettagli d ON d.idheader = o.idrow AND d.tipodoc = 'PDA_OFFERTE' and t.NumeroLotto = d.NumeroLotto and d.Voce = 0 

--		WHERE C.tIPODOC = 'PDA_CONCORSO' and c.deleted = 0 and d.idheader is null

--	--	and c.id = 200908




GO
