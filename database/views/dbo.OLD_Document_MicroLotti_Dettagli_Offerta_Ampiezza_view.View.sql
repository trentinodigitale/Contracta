USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Document_MicroLotti_Dettagli_Offerta_Ampiezza_view]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [dbo].[OLD_Document_MicroLotti_Dettagli_Offerta_Ampiezza_view] as 

select D.* 
	
	, case  when 
				--se la busta firmata tutte le colonne sono rese non editabili
				--isnull( DF.F1_SIGN_LOCK , 0 ) <> 0 or isnull( DF.F2_SIGN_LOCK , 0 ) <> 0 or isnull( DF.F3_SIGN_LOCK , 0 ) <> 0 or 
				isnull( DF.F4_SIGN_LOCK , 0 ) <> 0 
				--or isnull( F.F1_SIGN_LOCK , 0 ) <> 0 or isnull( F.F2_SIGN_LOCK , 0 ) <> 0 or isnull( F.F3_SIGN_LOCK , 0 ) <> 0 
				or isnull( F.F4_SIGN_LOCK , 0 ) <> 0 
				
				then 
					
					--case
						--when DM.value Is null then ' Graduatoria Sorteggio Posizione Aggiudicata Exequo StatoRiga EsitoRiga ValoreOfferta NumeroLotto Descrizione Qty PrezzoUnitario CauzioneMicrolotto CIG CodiceATC PrincipioAttivo FormaFarmaceutica Dosaggio Somministrazione UnitadiMisura Quantita ImportoBaseAstaUnitaria ImportoAnnuoLotto ImportoTriennaleLotto NoteLotto CodiceAIC QuantitaConfezione ClasseRimborsoMedicinale PrezzoVenditaConfezione AliquotaIva ScontoUlteriore EstremiGURI PrezzoUnitarioOfferta PrezzoUnitarioRiferimento TotaleOffertaUnitario ScorporoIVA PrezzoVenditaConfezioneIvaEsclusa PrezzoVenditaUnitario ScontoOffertoUnitario ScontoObbligatorioUnitario DenominazioneProdotto RagSocProduttore CodiceProdotto MarcaturaCE NumeroRepertorio NumeroCampioni Versamento PrezzoInLettere importoBaseAsta CampoTesto_1 CampoTesto_2 CampoTesto_3 CampoTesto_4 CampoTesto_5 CampoTesto_6 CampoTesto_7 CampoTesto_8 CampoTesto_9 CampoTesto_10 CampoNumerico_1 CampoNumerico_2 CampoNumerico_3 CampoNumerico_4 CampoNumerico_5 CampoNumerico_6 CampoNumerico_7 CampoNumerico_8 CampoNumerico_9 CampoNumerico_10 Voce idHeaderLotto CampoAllegato_1 CampoAllegato_2 CampoAllegato_3 CampoAllegato_4 CampoAllegato_5 NumeroRiga PunteggioTecnico ValoreEconomico PesoVoce ValoreImportoLotto Variante CONTRATTO CODICE_AZIENDA_SANITARIA CODICE_REGIONALE DESCRIZIONE_CODICE_REGIONALE TARGET MATERIALE LATEX_FREE MISURE VOLUME ALTRE_CARATTERISTICHE CONFEZIONAMENTO_PRIMARIO PESO_CONFEZIONE DIMENSIONI_CONFEZIONE TEMPERATURA_CONSERVAZIONE QUANTITA_PRODOTTO_SINGOLO_PEZZO UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO UM_DOSAGGIO PARTITA_IVA_FORNITORE RAGIONE_SOCIALE_FORNITORE CODICE_ARTICOLO_FORNITORE DENOMINAZIONE_ARTICOLO_FORNITORE DATA_INIZIO_PERIODO_VALIDITA DATA_FINE_PERIODO_VALIDITA RIFERIMENTO_TEMPORALE_FABBISOGNO FABBISOGNO_PREVISTO PREZZO_OFFERTO_PER_UM CONTENUTO_DI_UM_CONFEZIONE PREZZO_CONFEZIONE_IVA_ESCLUSA PREZZO_PEZZO SCHEDA_PRODOTTO CODICE_CND DESCRIZIONE_CND CODICE_CPV DESCRIZIONE_CODICE_CPV LIVELLO CERTIFICAZIONI CARATTERISTICHE_SOCIALI_AMBIENTALI PREZZO_BASE_ASTA_UM_IVA_ESCLUSA VALORE_BASE_ASTA_IVA_ESCLUSA RAGIONE_SOCIALE_ATTUALE_FORNITORE PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE DATA_ULTIMO_CONTRATTO UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE VALORE_COMPLESSIVO_OFFERTA NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI NOTE_OPERATORE_ECONOMICO ONERI_SICUREZZA PARTITA_IVA_DEPOSITARIO RAGIONE_SOCIALE_DEPOSITARIO IDENTIFICATIVO_OGGETTO_INIZIATIVA AREA_MERCEOLOGICA PERC_SCONTO_FISSATA_PER_LEGGE ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1 ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2 ADESIONE_PAYBACK DescrizioneAIC ValoreAccessorioTecnico TipoAcquisto Subordinato ArticoliPrimari SelRow Erosione ValoreSconto ValoreRibasso PunteggioTecnicoAssegnato PunteggioTecnicoRiparCriterio PunteggioTecnicoRiparTotale Campo_Intero_1 Campo_Intero_2 Campo_Intero_3 Campo_Intero_4 Campo_Intero_5 CODICE_CIVAB DESCRIZIONE_CIVAB CODICE_EAN CODICE_FISCALE_OPERATORE_ECONOMICO CODICE_FISCALE_PRODUTTORE CODICE_PARAF TIPO_REPERTORIO CampoAllegato_6 CampoAllegato_7 CampoAllegato_8 CampoAllegato_9 CampoAllegato_10 ONERI_SICUREZZA_NR TIPOLOGIA_FORNITURA CampoTesto_11 CampoTesto_12 CampoTesto_13 CampoTesto_14 CampoTesto_15 CampoTesto_16 CampoTesto_17 CampoTesto_18 CampoTesto_19 CampoTesto_20 CampoNumerico_11 CampoNumerico_12 CampoNumerico_13 CampoNumerico_14 CampoNumerico_15 CampoNumerico_16 CampoNumerico_17 CampoNumerico_18 CampoNumerico_19 CampoNumerico_20 CampoAllegato_11 CampoAllegato_12 CampoAllegato_13 CampoAllegato_14 CampoAllegato_15 CampoAllegato_16 CampoAllegato_17 CampoAllegato_18 CampoAllegato_19 CampoAllegato_20 Campo_Intero_6 Campo_Intero_7 Campo_Intero_8 Campo_Intero_9 Campo_Intero_10 Campo_Intero_11 Campo_Intero_12 Campo_Intero_13 Campo_Intero_14 Campo_Intero_15 Campo_Intero_16 Campo_Intero_17 Campo_Intero_18 Campo_Intero_19 Campo_Intero_20 PrezzoVenditaConfezioneIvaInclusa STERILE MONOUSO QT_NUM_PRODOTTO_SINGOLO_PEZZO PEZZI_PER_CONFEZIONE COSTI_MANODOPERA PercAgg Dominio_SiNo Intervallo_0_24 Dominio_SiNo_2 Dominio_SiNo_3 CODIFICA_ARTICOLO_OE_PEZZO_SINGOLO PERC_RIBASSO Temperatura_minima_di_conservazione Temperatura_massima_di_conservazione Ftalati_free Infiammabile Presenza_medicinali Sostanza_corrosiva Sostanza_tossica Sostanza_velenosa Classe_di_Rimborsabilita ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA3 PunteggioEconomicoAssegnato Dominio_SiNo_4 Dominio_SiNo_5 Dominio_SiNo_6 Dominio_SiNo_7 Dominio_SiNo_8 Dominio_SiNo_9 Dominio_SiNo_10 Dominio_SiNo_11 Dominio_SiNo_12 Dominio_SiNo_13 Rialzo_Offerta_Unitario CODICE_ISO CODICE_REF COMODATO_DUSO CONFEZIONAMENTO_SECONDARIO_ECOCOMPATIBILE CONTENUTO_DI_UP_PER_CONFEZIONE DEFINED_DAILY_DOSE DENOMINAZIONE_ARTICOLO_COMPLETA DENOMINAZIONE_ARTICOLO_SINTETICA DENOMINAZIONE_COMMERCIALE DESCRIZIONE_COMPLETA_PARAF_BDF DOSAGGIO_QTA_PER_PRINCIPIO_ATTIVO FARMACO_ESCLUSIVO FATTORE_PRODUTTIVO INCLUSIONE_PHT NUMERO_UNITA_POSOLOGICA_CONTENUTA_INT_BANCALE PREZZO_AL_PUBBLICO_PER_CONFEZIONEivainclusa SCADENZA_BREVETTO SCHEDA_DI_SICUREZZA SCHEDA_TECNICA_PRODOTTO VALORE_UNITARIO_OFFERTO_IVA_ESCLUSA IMPORTO_OPZIONI IMPORTO_ATTUAZIONE_SICUREZZA PROGRESSIVO_RIGA DATA_CONSEGNA CODICE_WBS DESCRIZIONE_WBS '
						--else 
						dbo.GetPos(DM.value,'###',3)
							
					--end
			else 
				
				case
					--se non trovo sul modello l'informazione con le colonne NON EDITABILI
					--oppure si tratta di una monolotto con una sola riga lascio tutto editabile
				    when DM.value is null  or ( DETT_GARA.Divisione_lotti = '0' and DG.Id is null)  then ''
					
					--sono sulla voce 0 delle gare che hanno voci (monolotto o con lotti)
					when d.voce = 0 and Divisione_lotti <> '2' then dbo.GetPos(DM.value,'###',1)

					--sono sulle voci delle gare che hanno voci (monolotto o con lotti)
					when d.voce <> 0  and Divisione_lotti <> '2' then dbo.GetPos(DM.value,'###',2)

					--sono le gare a lotti senza voci
					else ''
				end 

		end as 	NotEditable
	, case  when 
				isnull( DF.F1_SIGN_LOCK , 0 ) <> 0 or isnull( DF.F2_SIGN_LOCK , 0 ) <> 0 or isnull( DF.F3_SIGN_LOCK , 0 ) <> 0 or isnull( DF.F4_SIGN_LOCK , 0 ) <> 0 
				or isnull( F.F1_SIGN_LOCK , 0 ) <> 0 or isnull( F.F2_SIGN_LOCK , 0 ) <> 0 or isnull( F.F3_SIGN_LOCK , 0 ) <> 0 or isnull( F.F4_SIGN_LOCK , 0 ) <> 0 
				
			then 'nodisegno.gif'
			else '../toolbar/Delete_Light.GIF'
		end as 	FNZ_DEL
	
	from Document_MicroLotti_Dettagli D with (nolock)
			
			--salgo su offerta
			inner join ctl_doc O  with (nolock) on O.id = D.idheader  and O.tipodoc in ('OFFERTA' , 'OFFERTA_ASTA' )
			
			--salgo sulla gara
			inner join ctl_doc G  with (nolock) on G.id = O.linkeddoc and G.tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO' , 'BANDO_ASTA')
			
			--salgo sui dett della gara 
			inner join Document_Bando DETT_GARA with (nolock) on DETT_GARA.idHeader = G.Id 

			--salgo sui dettagli della gara per capire se la monolotto ha una riga oppure no
			left join Document_MicroLotti_Dettagli DG with (nolock) on DG.IdHeader = G.Id and DG.TipoDoc = G.TipoDoc 
																		and DETT_GARA.Divisione_lotti =0 and DG.NumeroRiga =1 
																		
			--salgo sul modello di gara
			left join CTL_DOC_Value gg1 with (nolock) on gg1.IdHeader = G.id and gg1.DSE_ID = 'TESTATA_PRODOTTI' and gg1.DZT_Name = 'id_modello'
			left join CTL_DOC_Value gg2 with (nolock) on gg2.IdHeader = isnull(gg1.Value,0) and gg2.DSE_ID = 'AMBITO' and gg2.DZT_Name = 'TipoModelloAmpiezzaDiGamma'

			left join ctl_doc M  with (nolock) on M.id = Gg2.Value  and M.tipodoc ='CONFIG_MODELLI' and M.JumpCheck = 'AMPIEZZA_DI_GAMMA'
			left join CTL_DOC_Value DM with (nolock) on DM.IdHeader = M.id and DM.dse_id='STATO_MODELLO' and DM.DZT_Name ='colonne_non_editabili'
		
			left join Document_Microlotto_Firme DF with (nolock) on DF.IdHEader=D.idheaderlotto
			left join CTL_DOC_SIGN F with (nolock) on F.IdHEader=D.idheader

			

GO
