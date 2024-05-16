USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_DRILL_MICROLOTTO_LISTA_MONOLOTTO_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_PDA_DRILL_MICROLOTTO_LISTA_MONOLOTTO_VIEW] as

	select 	 m.id as IdRowLottoBando 
			, o.aziRagioneSociale
			--,od.*
			,od.[Id]
			,od.[IdHeader]
			,od.[TipoDoc]
			,od.[Graduatoria]
			,od.[Sorteggio]
			,od.[Posizione]
			,od.[Aggiudicata]
			,od.[Exequo]
			,od.[StatoRiga]
			, case 
				when od.VALOREIMPORTOLOTTOORIGINARIO is not null then ISNULL(od.[EsitoRiga],'') + ' Valore originario di aggiudicazione pari a  ' +  dbo.FormatMoney(od.VALOREIMPORTOLOTTOORIGINARIO) + '€' 
				else od.[EsitoRiga]
			end as [EsitoRiga]
			,od.[ValoreOfferta]
			,od.[NumeroLotto]
			,od.[Descrizione]
			,od.[Qty]
			,od.[PrezzoUnitario]
			,od.[CauzioneMicrolotto]
			,od.[CIG]
			,od.[CodiceATC]
			,od.[PrincipioAttivo]
			,od.[FormaFarmaceutica]
			,od.[Dosaggio]
			,od.[Somministrazione]
			,od.[UnitadiMisura]
			,od.[Quantita]
			,od.[ImportoBaseAstaUnitaria]
			,od.[ImportoAnnuoLotto]
			,od.[ImportoTriennaleLotto]
			,od.[NoteLotto]
			,od.[CodiceAIC]
			,od.[QuantitaConfezione]
			,od.[ClasseRimborsoMedicinale]
			,od.[PrezzoVenditaConfezione]
			,od.[AliquotaIva]
			,od.[ScontoUlteriore]
			,od.[EstremiGURI]
			,od.[PrezzoUnitarioOfferta]
			,od.[PrezzoUnitarioRiferimento]
			,od.[TotaleOffertaUnitario]
			,od.[ScorporoIVA]
			,od.[PrezzoVenditaConfezioneIvaEsclusa]
			,od.[PrezzoVenditaUnitario]
			,od.[ScontoOffertoUnitario]
			,od.[ScontoObbligatorioUnitario]
			,od.[DenominazioneProdotto]
			,od.[RagSocProduttore]
			,od.[CodiceProdotto]
			,od.[MarcaturaCE]
			,od.[NumeroRepertorio]
			,od.[NumeroCampioni]
			,od.[Versamento]
			,od.[PrezzoInLettere]
			,od.[importoBaseAsta]
			,od.[CampoTesto_1]
			,od.[CampoTesto_2]
			,od.[CampoTesto_3]
			,od.[CampoTesto_4]
			,od.[CampoTesto_5]
			,od.[CampoTesto_6]
			,od.[CampoTesto_7]
			,od.[CampoTesto_8]
			,od.[CampoTesto_9]
			,od.[CampoTesto_10]
			,od.[CampoNumerico_1]
			,od.[CampoNumerico_2]
			,od.[CampoNumerico_3]
			,od.[CampoNumerico_4]
			,od.[CampoNumerico_5]
			,od.[CampoNumerico_6]
			,od.[CampoNumerico_7]
			,od.[CampoNumerico_8]
			,od.[CampoNumerico_9]
			,od.[CampoNumerico_10]
			,od.[Voce]
			,od.[idHeaderLotto]
			,od.[CampoAllegato_1]
			,od.[CampoAllegato_2]
			,od.[CampoAllegato_3]
			,od.[CampoAllegato_4]
			,od.[CampoAllegato_5]
			,od.[NumeroRiga]
			,od.[PunteggioTecnico]
			,od.[ValoreEconomico]
			,od.[PesoVoce]
			,od.[ValoreImportoLotto]
			,od.[Variante]
			,od.[CONTRATTO]
			,od.[CODICE_AZIENDA_SANITARIA]
			,od.[CODICE_REGIONALE]
			,od.[DESCRIZIONE_CODICE_REGIONALE]
			,od.[TARGET]
			,od.[MATERIALE]
			,od.[LATEX_FREE]
			,od.[MISURE]
			,od.[VOLUME]
			,od.[ALTRE_CARATTERISTICHE]
			,od.[CONFEZIONAMENTO_PRIMARIO]
			,od.[PESO_CONFEZIONE]
			,od.[DIMENSIONI_CONFEZIONE]
			,od.[TEMPERATURA_CONSERVAZIONE]
			,od.[QUANTITA_PRODOTTO_SINGOLO_PEZZO]
			,od.[UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO]
			,od.[UM_DOSAGGIO]
			,od.[PARTITA_IVA_FORNITORE]
			,od.[RAGIONE_SOCIALE_FORNITORE]
			,od.[CODICE_ARTICOLO_FORNITORE]
			,od.[DENOMINAZIONE_ARTICOLO_FORNITORE]
			,od.[DATA_INIZIO_PERIODO_VALIDITA]
			,od.[DATA_FINE_PERIODO_VALIDITA]
			,od.[RIFERIMENTO_TEMPORALE_FABBISOGNO]
			,od.[FABBISOGNO_PREVISTO]
			,od.[PREZZO_OFFERTO_PER_UM]
			,od.[CONTENUTO_DI_UM_CONFEZIONE]
			,od.[PREZZO_CONFEZIONE_IVA_ESCLUSA]
			,od.[PREZZO_PEZZO]
			,od.[SCHEDA_PRODOTTO]
			,od.[CODICE_CND]
			,od.[DESCRIZIONE_CND]
			,od.[CODICE_CPV]
			,od.[DESCRIZIONE_CODICE_CPV]
			,od.[LIVELLO]
			,od.[CERTIFICAZIONI]
			,od.[CARATTERISTICHE_SOCIALI_AMBIENTALI]
			,od.[PREZZO_BASE_ASTA_UM_IVA_ESCLUSA]
			,od.[VALORE_BASE_ASTA_IVA_ESCLUSA]
			,od.[RAGIONE_SOCIALE_ATTUALE_FORNITORE]
			,od.[PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE]
			,od.[DATA_ULTIMO_CONTRATTO]
			,od.[UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE]
			,od.[VALORE_COMPLESSIVO_OFFERTA]
			,od.[NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI]
			,od.[NOTE_OPERATORE_ECONOMICO]
			,od.[ONERI_SICUREZZA]
			,od.[PARTITA_IVA_DEPOSITARIO]
			,od.[RAGIONE_SOCIALE_DEPOSITARIO]
			,od.[IDENTIFICATIVO_OGGETTO_INIZIATIVA]
			,od.[AREA_MERCEOLOGICA]
			,od.[PERC_SCONTO_FISSATA_PER_LEGGE]
			,od.[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1]
			,od.[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2]
			,od.[ADESIONE_PAYBACK]
			,od.[DescrizioneAIC]
			,od.[ValoreAccessorioTecnico]
			,od.[TipoAcquisto]
			,od.[Subordinato]
			,od.[ArticoliPrimari]
			,od.[SelRow]
			,od.[Erosione]
			,od.[ValoreSconto]
			,od.[ValoreRibasso]
			,od.[PunteggioTecnicoAssegnato]
			,od.[PunteggioTecnicoRiparCriterio]
			,od.[PunteggioTecnicoRiparTotale]
			,od.[Campo_Intero_1]
			,od.[Campo_Intero_2]
			,od.[Campo_Intero_3]
			,od.[Campo_Intero_4]
			,od.[Campo_Intero_5]
			,od.[CODICE_CIVAB]
			,od.[DESCRIZIONE_CIVAB]
			,od.[CODICE_EAN]
			,od.[CODICE_FISCALE_OPERATORE_ECONOMICO]
			,od.[CODICE_FISCALE_PRODUTTORE]
			,od.[CODICE_PARAF]
			,od.[TIPO_REPERTORIO]
			,od.[CampoAllegato_6]
			,od.[CampoAllegato_7]
			,od.[CampoAllegato_8]
			,od.[CampoAllegato_9]
			,od.[CampoAllegato_10]
			,od.[ONERI_SICUREZZA_NR]
			,od.[TIPOLOGIA_FORNITURA]
			,od.[CampoTesto_11]
			,od.[CampoTesto_12]
			,od.[CampoTesto_13]
			,od.[CampoTesto_14]
			,od.[CampoTesto_15]
			,od.[CampoTesto_16]
			,od.[CampoTesto_17]
			,od.[CampoTesto_18]
			,od.[CampoTesto_19]
			,od.[CampoTesto_20]
			,od.[CampoNumerico_11]
			,od.[CampoNumerico_12]
			,od.[CampoNumerico_13]
			,od.[CampoNumerico_14]
			,od.[CampoNumerico_15]
			,od.[CampoNumerico_16]
			,od.[CampoNumerico_17]
			,od.[CampoNumerico_18]
			,od.[CampoNumerico_19]
			,od.[CampoNumerico_20]
			,od.[CampoAllegato_11]
			,od.[CampoAllegato_12]
			,od.[CampoAllegato_13]
			,od.[CampoAllegato_14]
			,od.[CampoAllegato_15]
			,od.[CampoAllegato_16]
			,od.[CampoAllegato_17]
			,od.[CampoAllegato_18]
			,od.[CampoAllegato_19]
			,od.[CampoAllegato_20]
			,od.[Campo_Intero_6]
			,od.[Campo_Intero_7]
			,od.[Campo_Intero_8]
			,od.[Campo_Intero_9]
			,od.[Campo_Intero_10]
			,od.[Campo_Intero_11]
			,od.[Campo_Intero_12]
			,od.[Campo_Intero_13]
			,od.[Campo_Intero_14]
			,od.[Campo_Intero_15]
			,od.[Campo_Intero_16]
			,od.[Campo_Intero_17]
			,od.[Campo_Intero_18]
			,od.[Campo_Intero_19]
			,od.[Campo_Intero_20]
			,od.[PrezzoVenditaConfezioneIvaInclusa]
			,od.[STERILE]
			,od.[MONOUSO]
			,od.[QT_NUM_PRODOTTO_SINGOLO_PEZZO]
			,od.[PEZZI_PER_CONFEZIONE]
			,od.[COSTI_MANODOPERA]
			,od.[PercAgg]
			,od.[Dominio_SiNo]
			,od.[Intervallo_0_24]
			,od.[Dominio_SiNo_2]
			,od.[Dominio_SiNo_3]
			,od.[CODIFICA_ARTICOLO_OE_PEZZO_SINGOLO]
			,od.[PERC_RIBASSO]
			,od.[Temperatura_minima_di_conservazione]
			,od.[Temperatura_massima_di_conservazione]
			,od.[Ftalati_free]
			,od.[Infiammabile]
			,od.[Presenza_medicinali]
			,od.[Sostanza_corrosiva]
			,od.[Sostanza_tossica]
			,od.[Sostanza_velenosa]
			,od.[Classe_di_Rimborsabilita]
			,od.[ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA3]
			,od.[PunteggioEconomicoAssegnato]
			,od.[Dominio_SiNo_4]
			,od.[Dominio_SiNo_5]
			,od.[Dominio_SiNo_6]
			,od.[Dominio_SiNo_7]
			,od.[Dominio_SiNo_8]
			,od.[Dominio_SiNo_9]
			,od.[Dominio_SiNo_10]
			,od.[Dominio_SiNo_11]
			,od.[Dominio_SiNo_12]
			,od.[Dominio_SiNo_13]
			,od.[Rialzo_Offerta_Unitario]
			,od.[CODICE_ISO]
			,od.[CODICE_REF]
			,od.[COMODATO_DUSO]
			,od.[CONFEZIONAMENTO_SECONDARIO_ECOCOMPATIBILE]
			,od.[CONTENUTO_DI_UP_PER_CONFEZIONE]
			,od.[DEFINED_DAILY_DOSE]
			,od.[DENOMINAZIONE_ARTICOLO_COMPLETA]
			,od.[DENOMINAZIONE_ARTICOLO_SINTETICA]
			,od.[DENOMINAZIONE_COMMERCIALE]
			,od.[DESCRIZIONE_COMPLETA_PARAF_BDF]
			,od.[DOSAGGIO_QTA_PER_PRINCIPIO_ATTIVO]
			,od.[FARMACO_ESCLUSIVO]
			,od.[FATTORE_PRODUTTIVO]
			,od.[INCLUSIONE_PHT]
			,od.[NUMERO_UNITA_POSOLOGICA_CONTENUTA_INT_BANCALE]
			,od.[PREZZO_AL_PUBBLICO_PER_CONFEZIONEivainclusa]
			,od.[SCADENZA_BREVETTO]
			,od.[SCHEDA_DI_SICUREZZA]
			,od.[SCHEDA_TECNICA_PRODOTTO]
			,od.[VALORE_UNITARIO_OFFERTO_IVA_ESCLUSA]
			,od.[IMPORTO_OPZIONI]
			,od.[IMPORTO_ATTUAZIONE_SICUREZZA]
			,od.[PROGRESSIVO_RIGA]
			,od.[DATA_CONSEGNA]
			,od.[CODICE_WBS]
			,od.[DESCRIZIONE_WBS]
			,od.[DICHIARAZIONE_LATEX_GLUTEN_LACTOS_FREE]
			,od.[PRODOTTO_IN_ESCLUSIVA]
			,od.[ELENCO_AIC_DISPONIBILI]
			,od.[PRESENZA_DI_GLUTINE]
			,od.[PRESENZA_DI_LATTOSIO]
			,od.[ALL_FIELD]
			,od.[ClasseIscriz_S]
			,od.[AREA_DI_CONSEGNA]
			,od.[FotoProdotto]
			,od.[IdRigaRiferimento]
			,od.[MULTIPLI_ORDINABILI]
			,od.[TAGLIA]
			,od.[MODALITA_DI_CONSERVAZIONE]
			,od.[CODICE_DM_PMC]
			,od.[SCHEDA_TECNICA_LINK]
			,od.[CODICE_BDR]
			,od.[MODALITA_DI_CONSERVAZIONE_DOM]
			,od.[VALOREIMPORTOLOTTOORIGINARIO]
			, case when isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) < 0 then null else isnull( od.ValoreOfferta , 0 ) - isnull( od.PunteggioTecnico , 0 ) end as PunteggioEconomico
			, od.id as IdOffertaLotto	
			, dbo.PDA_MICROLOTTI_ListaMotivazioni_LOTTO( od.id , 'ECONOMICA' ) as Motivazione
			, o.idMsg 
			, o.TipoDoc as OPEN_DOC_NAME
			, d.id as idPDA

			, case when ( isnull( BD.Value ,'0') = '1' or isnull( v1.Value ,'0') = '1' )  and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bRead
			, case when ( isnull( BD2.Value ,'0') = '1' or ( isnull( v2.Value ,'0') = '1'  and divisione_lotti = '0' ) ) and isnull( dof.StatoRiga , '' )  <> '99' then '0' else '1' end as bReadEconomica

			, cast( NumRiga as int ) as NumRiga
			, o.StatoPDA
			, ba.InversioneBuste

			, case 
				when m.StatoRiga in ( 'Completo' , 'Valutato' , 'daValutare' , 'InValutazione' ,    'SecondaFaseTecnica' , 'PrimaFaseTecnica' ) then '1'
				
				else
					case 					
						when  od.StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) then '1'
						when  od.StatoRiga in ( 'decaduta' ) then '2-' + '[' + str( isnull( od.ValoreImportoLotto , 0.0 ) , 20 , 5 ) + ']'
						when  od.StatoRiga in ( 'anomalo' , 'decaduta' ) then '3-' + '[' + str( isnull( od.ValoreImportoLotto , 0.0 )  , 20 , 5 ) + ']'
						when  od.StatoRiga  in ( 'esclusoEco' ,'escluso' , 'NonConforme' ) then '4-' + '[' + str( isnull( od.ValoreImportoLotto , 0.0 )  , 20 , 5 ) + ']'
						else '0'
					end

				end as Ordinamento,
				
			  case when pending.idOfferta is null then '' else 'PENDING' end as Stato_Firma_PDA_AMM

		from 
			
			CTL_DOC d with(nolock)

				INNER JOIN Document_MicroLotti_Dettagli m with(nolock) on d.id = m.IdHeader and  m.tipoDoc = 'PDA_MICROLOTTI' AND m.voce = 0 
			
				--Document_MicroLotti_Dettagli m with(nolock)
				--inner join CTL_DOC d with(nolock) on d.id = m.IdHeader and  m.tipoDoc = 'PDA_MICROLOTTI'  --d.LinkedDoc = m.IdHeader
				--inner join ctl_doc gara with(nolock) on gara.id = d.linkeddoc

				--left join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) on c.idBando = gara.id and m.NumeroLotto = c.N_Lotto 

				inner join Document_Bando ba with (nolock) on d.LinkedDoc = ba.idHeader and ba.divisione_lotti = '0'
			
				inner join Document_PDA_OFFERTE o with(nolock) on d.id =  o.idheader

				inner join Document_MicroLotti_Dettagli od with(nolock) on o.idRow = od.idHeader and od.tipoDoc = 'PDA_OFFERTE' and od.NumeroLotto = m.NumeroLotto and od.voce = 0 -- o.IdMsgFornitore = od.idHeader and od.NumeroLotto = m.NumeroLotto
			
				left outer join aziende a with(nolock) on a.idazi = o.idAziPartecipante


				-- prendo il dettaglio offerto dal fornitore
				left outer join Document_MicroLotti_Dettagli dof with(nolock) on o.IdMsgFornitore = dof.idheader and 
															( (dof.TipoDoc ='OFFERTA' and o.TipoDoc = 'OFFERTA') or ( dof.TipoDoc ='55;186' and isnull(o.TipoDoc , '' ) = '' ) )
																and dof.Voce = 0 and dof.NumeroLotto = m.NumeroLotto


				---- recupera l'evidenza di lettura del documento
				left outer join CTL_DOC_VALUE BD with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'OFFERTA' and o.idMsg = BD.idHeader and BD.DSE_ID = 'OFFERTA_BUSTA_TEC' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
				left outer join CTL_DOC_VALUE v1 with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'OFFERTA' and o.idMsg = v1.idHeader and v1.DSE_ID = 'BUSTA_TECNICA' and v1.DZT_Name = 'LettaBusta' 


				left outer join CTL_DOC_VALUE BD2 with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'OFFERTA' and o.idMsg = BD2.idHeader and BD2.DSE_ID = 'OFFERTA_BUSTA_ECO' and BD2.DZT_Name = 'LettaBusta' and dof.id = BD2.row
				left outer join CTL_DOC_VALUE v2 with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on o.Tipodoc = 'OFFERTA' and o.idMsg = v2.idHeader and v2.DSE_ID = 'BUSTA_ECONOMICA' and v2.DZT_Name = 'LettaBusta' 

				left join ( 
							select da.LinkedDoc as idOfferta 
								from ctl_doc da with(nolock)
										inner join Document_Offerta_Allegati al with(nolock) on al.Idheader = da.Id and al.SectionName = 'ECONOMICA' and al.statoFirma = 'SIGN_PENDING'
								where da.tipodoc = 'OFFERTA_ALLEGATI' and da.Deleted = 0
								group by LinkedDoc
		
						) pending on pending.idOfferta = o.IdMsg

		where d.tipodoc='PDA_MICROLOTTI' and d.deleted = 0 










GO
