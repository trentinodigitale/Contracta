USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_Document_MicroLotti_Dettagli_view]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  VIEW [dbo].[OLD2_Document_MicroLotti_Dettagli_view] as
select b.TipoBando , 
	   doc.StatoDoc,
	   PT.Value as PunteggioTecnico ,
	   PE.Value as PunteggioEconomico, 
	   PTM.Value as PunteggioTecMin,
	   d.Id, 
	   d.IdHeader, 
	   d.TipoDoc, 
	   Graduatoria, 
	   Sorteggio, 
	   Posizione,
	   Aggiudicata, 
	   Exequo, 
	   StatoRiga, 
	   --EsitoRiga, 

	   case 
			--se esito riga già non è ok lo ritorno
			when EsitoRiga <> '<img src="../images/Domain/State_OK.gif">' then EsitoRiga

			else
				
				--se esitoriga è ok	
				case 

					--se non ci sono criteri di valutazione specializzati come prima
					when DC.CriterioAggiudicazioneGara IS NULL then EsitoRiga

					else
				
						--allora controllo l'esito dei criteri valutazione specializzati del lotto
						case 
							when EC.EsitoCriteriValutazioneLotto='' then Esitoriga
							else EC.EsitoCriteriValutazioneLotto
						end 

				end
	   end as EsitoRiga,

	   ValoreOfferta, 
	   NumeroLotto, 
	   d.Descrizione, 
	   Qty, 
	   PrezzoUnitario, 
	   CauzioneMicrolotto, 
	   d.CIG, 
	   CodiceATC, 
	   PrincipioAttivo, 
	   FormaFarmaceutica, 
	   Dosaggio, 
	   Somministrazione, 
	   UnitadiMisura, 
	   Quantita, 
	   ImportoBaseAstaUnitaria, 
	   ImportoAnnuoLotto,
	   ImportoTriennaleLotto, 
	   NoteLotto, 
	   CodiceAIC, 
	   QuantitaConfezione, 
	   ClasseRimborsoMedicinale, 
	   PrezzoVenditaConfezione, 
	   AliquotaIva,
	   ScontoUlteriore, 
	   EstremiGURI, 
	   PrezzoUnitarioOfferta, 
	   PrezzoUnitarioRiferimento, 
	   TotaleOffertaUnitario, 
	   ScorporoIVA,
	   PrezzoVenditaConfezioneIvaEsclusa, 
	   PrezzoVenditaUnitario,
	   ScontoOffertoUnitario, 
	   ScontoObbligatorioUnitario, 
	   DenominazioneProdotto, 
	   RagSocProduttore, 
	   CodiceProdotto, 
	   MarcaturaCE, 
	   NumeroRepertorio, 
	   NumeroCampioni, 
	   Versamento, 
	   PrezzoInLettere, 
	   d.importoBaseAsta, 
	   CampoTesto_1, 
	   CampoTesto_2, 
	   CampoTesto_3, 
	   CampoTesto_4, 
	   CampoTesto_5, 
	   CampoTesto_6, 
	   CampoTesto_7, 
	   CampoTesto_8, 
	   CampoTesto_9, 
	   CampoTesto_10, 
	   CampoNumerico_1, 
	   CampoNumerico_2, 
	   CampoNumerico_3, 
	   CampoNumerico_4, 
	   CampoNumerico_5,	     
	   CampoNumerico_6, 
	   CampoNumerico_7, 
	   CampoNumerico_8, 
	   CampoNumerico_9, 
	   CampoNumerico_10,
	   Voce, 
	   idHeaderLotto, 
	   CampoAllegato_1, 
	   CampoAllegato_2, 
	   CampoAllegato_3, 
	   CampoAllegato_4, 
	   CampoAllegato_5, 
	   NumeroRiga,	
	   d.idHeader as LinkedDoc , 
	   bs.ProtocolloBando , 
	   doc.Fascicolo , 
	   doc.Azienda , 
	   doc.Destinatario_Azi,
	   doc.Body , 
	   doc.RichiestaFirma ,
	   doc.Protocollo ,
	   doc.StatoFunzionale,
	   
	   case 
			when DC.CriterioAggiudicazioneGara IS NULL then
		
				--se non esistono specializzazioni dei criteri come prima
				case 
					when bw.somma_punt_lotto = PT.Value then 'valutato_ok'
					when bw.somma_punt_lotto IS NULL then  'da_valutare' 
					when NOT bw.somma_punt_lotto IS NULL and bw.somma_punt_lotto <> PT.Value then 'valutato_err' 
				end 
		
			else

				--se esistono specializzazioni dei criteri vado sui dettagli
				case 
					when EC.EsitoCriteriValutazioneLotto='' then
						
						case 
							when DC.CriterioAggiudicazioneGara<>'15532' and DC.CriterioAggiudicazioneGara<>'25532'   then 'valutato_ok'
							else 

								case 
									when  round( bw.somma_punt_lotto , 2 ) =  round( DPT.PunteggioTecnico , 2 ) then 'valutato_ok'
									when bw.somma_punt_lotto IS NULL then  'da_valutare' 
									when NOT bw.somma_punt_lotto IS NULL and round( bw.somma_punt_lotto , 2 ) <> round( DPT.PunteggioTecnico , 2 ) then 'valutato_err' 
								end 
						end
							
					else  'valutato_err' 
				end

		end as criteri_di_valutaz,
	   FE.value as FormulaEcoSDA,
	   FE.value as FormulaEconomica,
	   CX.value as Coefficiente_X,
	   bw.somma_punt_lotto,
	    ValoreEconomico, PesoVoce, ValoreImportoLotto, Variante, CONTRATTO, CODICE_AZIENDA_SANITARIA, CODICE_REGIONALE, DESCRIZIONE_CODICE_REGIONALE, TARGET, MATERIALE, LATEX_FREE, MISURE, VOLUME, ALTRE_CARATTERISTICHE, CONFEZIONAMENTO_PRIMARIO, PESO_CONFEZIONE, DIMENSIONI_CONFEZIONE, TEMPERATURA_CONSERVAZIONE, QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO, UM_DOSAGGIO,  PARTITA_IVA_FORNITORE, RAGIONE_SOCIALE_FORNITORE, CODICE_ARTICOLO_FORNITORE, DENOMINAZIONE_ARTICOLO_FORNITORE, DATA_INIZIO_PERIODO_VALIDITA, DATA_FINE_PERIODO_VALIDITA, RIFERIMENTO_TEMPORALE_FABBISOGNO, FABBISOGNO_PREVISTO, PREZZO_OFFERTO_PER_UM, CONTENUTO_DI_UM_CONFEZIONE, PREZZO_CONFEZIONE_IVA_ESCLUSA, PREZZO_PEZZO, SCHEDA_PRODOTTO, CODICE_CND, DESCRIZIONE_CND, CODICE_CPV, DESCRIZIONE_CODICE_CPV, LIVELLO, CERTIFICAZIONI, CARATTERISTICHE_SOCIALI_AMBIENTALI, PREZZO_BASE_ASTA_UM_IVA_ESCLUSA, VALORE_BASE_ASTA_IVA_ESCLUSA, RAGIONE_SOCIALE_ATTUALE_FORNITORE, PREZZO_UM_IVA_ESCLUSA_ATTUALE_FORNITORE, DATA_ULTIMO_CONTRATTO, UM_UNITA_POSOLOGICA_CONTENUTA_INTERNO_DEL_BANCALE, VALORE_COMPLESSIVO_OFFERTA, NOTE_ENTI_STRUTTURE_AMMINISTRAZIONI, NOTE_OPERATORE_ECONOMICO, ONERI_SICUREZZA, PARTITA_IVA_DEPOSITARIO, RAGIONE_SOCIALE_DEPOSITARIO, IDENTIFICATIVO_OGGETTO_INIZIATIVA, AREA_MERCEOLOGICA,PERC_SCONTO_FISSATA_PER_LEGGE,ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1,ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA2,ADESIONE_PAYBACK
	   ,b.TipoGiudizioTecnico
	   
	   ,case 
			when DC.CriterioAggiudicazioneGara IS NULL then
				--se non esistono criteri specializzati	
				case 
					--in testata OEPV opp. Conformità <> no
					when b.CriterioAggiudicazioneGara='15532' or b.CriterioAggiudicazioneGara='25532' or b.Conformita<>'No' then '1'
					else '0'
				end
			else
				--se esiste una specializzaqzione dei criteri
				case 
					--sul dettaglio OEPV opp. COSTO FISSO  opp. Conformità <> no
					when DC.CriterioAggiudicazioneGara='15532' or DC.CriterioAggiudicazioneGara='25532' or DC1.Conformita<>'No' then '1'
					else '0'
				end

		end as PresenzaBustaTecnica
		,EC.EsitoCriteriValutazioneLotto as AnomalieCompilazioneCriteri
		,doc.Versione

		, doc.idpfu
		, b.TipoSceltaContraente

		, case when bs.TipoSceltaContraente = 'ACCORDOQUADRO' then 'yes' else 'no' end as AQ_RILANCIO_COMPETITVO
		
		, case when getdate() > bs.DataScadenzaOfferta  then '1' else '0' end as DATA_INVIO_SUPERATA 
		, bs.DataScadenzaOfferta
		, isnull( DC.CriterioAggiudicazioneGara , BS.CriterioAggiudicazioneGara ) as CriterioAggiudicazioneGara
		, ISNULL(b.Concessione,bs.Concessione) as Concessione
		, GARE_IN_MODIFICA_O_RETTIFICA
		, b.Visualizzazione_Offerta_Tecnica

		, bp.value as AttivaFilePending
		, b.GeneraConvenzione
		, isnull(DV.Value,0) as VersioneLinkedDoc
		,bs.ProceduraGara
		,cobust.value aS ControlloFirmaBuste
		, case 
			when isnull(AG.DZT_ValueDef, '') = '' then 'no'
			else 'si'
		end as PresenzaModuloAmpiezzaGamma
		--, isnull(RettTec.Id,0) AS RettificaOffertaTec
		--, isnull(RettEco.Id,0) AS RettificaOffertaEco
		--, isnull(CommTec.UtenteCommissione,0) as PresidenteTec
		--, isnull(CommEco.UtenteCommissione,0) as PresidenteEco
		--, isnull(FlagRettifica.Valore,0) as FlagRettifica

	from Document_MicroLotti_Dettagli d with(nolock)
		
		left outer join Document_Bando b with(nolock) on d.idheader = b.idheader
		
		LEFT OUTER JOIN CTL_DOC_VALUE PE with(nolock) on pe.DZT_NAME = 'PunteggioEconomico' and pe.idheader = b.idheader and pe.DSE_ID = 'CRITERI_ECO' and pe.Row = 0 
		LEFT OUTER JOIN CTL_DOC_VALUE PT with(nolock) on pt.DZT_NAME = 'PunteggioTecnico' and pt.idheader = b.idheader and pt.DSE_ID = 'CRITERI_ECO' and pt.Row = 0
		LEFT OUTER JOIN CTL_DOC_VALUE PTM with(nolock) on ptm.DZT_NAME = 'PunteggioTecMin' and ptm.idheader = b.idheader and ptm.DSE_ID = 'CRITERI_ECO' and ptm.Row = 0
		LEFT OUTER JOIN CTL_DOC_VALUE FE with(nolock) on FE.DZT_NAME = 'FormulaEcoSDA' and FE.idheader = b.idheader and FE.DSE_ID = 'CRITERI_ECO' and FE.Row = 0
		LEFT OUTER JOIN CTL_DOC_VALUE CX with(nolock) on CX.DZT_NAME = 'Coefficiente_X' and CX.idheader = b.idheader and CX.DSE_ID = 'CRITERI_ECO' and CX.Row = 0	
		left outer join CTL_DOC  doc with(nolock) on doc.id = d.idheader and doc.TipoDoc in ( 'OFFERTA','BANDO_SEMPLIFICATO' , 'BANDO_GARA' , 'BANDO_ASTA', 'TEMPLATE_GARA')
		
		left outer join Document_Bando bs with(nolock) on doc.LinkedDoc = bs.idheader and bs.idheader <> 0

		left join ctl_doc_value bp with(nolock) on bp.idheader = bs.idheader and bp.DSE_ID = 'PARAMETRI' and bp.DZT_Name = 'AttivaFilePending'

		left join ( select sum(PunteggioMax) as somma_punt_lotto,idheader,TipoDoc from Document_Microlotto_Valutazione with(nolock) group by idheader,tipoDoc ) bw on bw.idheader=d.id and bw.TipoDoc='LOTTO'
		left join ( select value as CriterioAggiudicazioneGara,idheader from Document_Microlotti_DOC_Value with(nolock) where dse_id='CRITERI_AGGIUDICAZIONE' and dzt_name='CriterioAggiudicazioneGara') DC on DC.idheader=d.id
		left join ( select value as Conformita,idheader from Document_Microlotti_DOC_Value with(nolock) where dse_id='CRITERI_AGGIUDICAZIONE' and dzt_name='Conformita') DC1 on DC1.idheader=d.id
		cross apply ( select dbo.GetEsitoCriteriValutazioneLotto(d.id) as EsitoCriteriValutazioneLotto ) EC
		left join ( select value as PunteggioTecnico, idheader from Document_Microlotti_DOC_Value with(nolock) where dse_id='CRITERI_ECO' and dzt_name='PunteggioTecnico') DPT on DPT.idheader=d.id
	
		cross join ( select dbo.GetBandiInRettificaOModifica( ) as GARE_IN_MODIFICA_O_RETTIFICA ) as girm
		
		left join Document_Microlotti_DOC_Value DV with (nolock) on d.Id = DV.IdHeader and DV.DSE_ID ='RETTIFICA' and DV.DZT_Name = 'IdDocRettifica'

		left join ctl_doc_value cobust with(nolock) on cobust.idheader = bs.idheader and cobust.DSE_ID = 'PARAMETRI' and cobust.DZT_Name = 'ControlloFirmaBuste'


		cross join ( select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%')  as AG


		----Flag Attivazione Rettifica Offerta
		--left join CTL_Parametri FlagRettifica with (nolock) on FlagRettifica.Contesto='CERTIFICATION' and FlagRettifica.Oggetto='certification_req_33245' and FlagRettifica.Proprieta = 'Visible'
			
		---- Recupero ID dei presidenti della commissione
		----Accedo al doc della commissione
		--left join CTL_DOC Commissione with (nolock) on doc.linkedDoc = Commissione.linkedDoc and Commissione.tipodoc = 'COMMISSIONE_PDA' and Commissione.StatoFunzionale = 'Pubblicato'
		----IdPfu Presidente Commissione Tecnica
		--left join Document_CommissionePda_Utenti CommTec with(nolock) on Commissione.id = CommTec.IdHeader and CommTec.RuoloCommissione = 15548 and CommTec.TipoCommissione = 'G'
		----IdPfu Presidente Commissione Economica
		--left join Document_CommissionePda_Utenti CommEco with(nolock) on Commissione.id = CommEco.IdHeader and CommEco.RuoloCommissione = 15548 and CommEco.TipoCommissione = 'C'

		--LEFT JOIN (
		--	SELECT
		--		RettTec.*,
		--		ROW_NUMBER() OVER (PARTITION BY RettTec.LinkedDoc ORDER BY RettTec.Id DESC) AS RowNum
		--	FROM
		--		CTL_DOC RettTec with (nolock)
		--	WHERE
		--		RettTec.TipoDoc = 'PDA_COMUNICAZIONE_GARA'
		--		AND RettTec.deleted = 0
		--		AND RettTec.StatoFunzionale = 'Inviato'
		--		AND SUBSTRING(RettTec.JumpCheck, 3, LEN(RettTec.JumpCheck) - 2) = 'RETTIFICA_TECNICA_OFFERTA'
		--) RettTec ON RettTec.LinkedDoc = doc.id AND RettTec.RowNum = 1

		--LEFT JOIN (
		--	SELECT
		--		RettEco.*,
		--		ROW_NUMBER() OVER (PARTITION BY RettEco.LinkedDoc ORDER BY RettEco.Id DESC) AS RowNum
		--	FROM
		--		CTL_DOC RettEco with (nolock)
		--	WHERE
		--		RettEco.TipoDoc = 'PDA_COMUNICAZIONE_GARA'
		--		AND RettEco.deleted = 0
		--		AND RettEco.StatoFunzionale = 'Inviato'
		--		AND SUBSTRING(RettEco.JumpCheck, 3, LEN(RettEco.JumpCheck) - 2) = 'RETTIFICA_ECONOMICA_OFFERTA'
		--) RettEco ON RettEco.LinkedDoc = doc.id AND RettEco.RowNum = 1;




GO
