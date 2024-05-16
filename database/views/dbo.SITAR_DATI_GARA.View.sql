USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_DATI_GARA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE view [dbo].[SITAR_DATI_GARA] as 

	select 
	
			D.id as idGara ,

			D.body  as W3OGGETTO1 , --Oggetto della gara ALFANUMERICO

			case 
				when dbo.PARAMETRI('SICOPAT','ATTIVA_IMPLEMENTAZIONE','ATTIVA','NO','-1') = 'SI' then
					case 
						when b.Divisione_lotti = '0' then --per le gare senza lotti
							case 
								when isnull(pcpa.pcp_CodiceAppalto, '') <> '' then pcpa.pcp_CodiceAppalto
								else isnull(s2.id_gara, 'NO_INTEGRAZIONE') --recupera dalla richiesta cig
							end
						when b.Divisione_lotti in ('1', '2') then --se la gara è a lotti
							case 
								when isnull(pcpa.pcp_CodiceAppalto, '') <> '' then pcpa.pcp_CodiceAppalto
								else isnull(B.CIG, 'NO_INTEGRAZIONE') --recupera campo CIG della docuent bando 
							end
					end
				ELSE
					case 
						when b.Divisione_lotti = '0' then isnull(s2.id_gara, 'NO_INTEGRAZIONE')
						else isnull(B.CIG, 'NO_INTEGRAZIONE')
					end
			END as W3IDGARA,

			--case when b.Divisione_lotti = '0' then isnull(s2.id_gara, 'NO_INTEGRAZIONE')
			--	 else isnull(B.CIG, 'NO_INTEGRAZIONE')
			--end as W3IDGARA , --Codice della gara restituito dall’Autorità alla richiesta del CIG ALFANUMERICO ( da fare per le monolotto )

			--ltrim( str( B.ImportoBaseAsta2 , 25 , 2 ) ) as W3I_GARA , --Importo della gara IMPORTO ( Importo Base Asta [quello senza oneri])
			ltrim( str( B.ImportoBaseAsta , 25 , 2 ) ) as W3I_GARA , --mod. att 402055. Importo della gara, il totale

			convert( varchar(19) , D.datainvio , 127 )  as W3DGURI , -- Data pubblicazione del bando sulla GURI DATA ( ho preso data invio non so di preciso dove recuperare e sulla gara specifica manca
			convert( varchar(19) , B.DataScadenzaOfferta , 127 ) as W3DSCADB , --Data scadenza DATA
			s2.modo_indizione as W9GAMOD_IND,
			--'4' as W9GAMOD_IND , --Modalità indizione gara TABELLATO W3008 ( da fare capire ) -- sostituito con Procedura che non prevede indizione
			s2.tipo_scheda as W9GAFLAG_ENT,
			--'O' as W9GAFLAG_ENT , -- Tipo di settore TABELLATO W3z08 ( da fare capire )
			s2.modo_realizzazione as W3TIPOAPP,
			--'9' as W3TIPOAPP , -- Modalità di realizzazione TABELLATO W3999  ( da fare capire ) -- sostituito con 'Accordo quadro/convenzione'
			'' as W3ID_TIPOL,
			--'6' as W3ID_TIPOL , -- Tipologia della stazione appaltante TABELLATO W3001 ( da fare capire )
			'true' as W9GASTIPULA , --La centrale di committenza procede alla stipula? SN ( da fare capire )

			----RUP
			u.pfuCodiceFiscale as CFTEC1 , -- Codice fiscale ALFANUMERICO (16)
			u.pfuCognome as COGTEI , -- Cognome del tecnico ALFANUMERICO (40) 
			u.pfunomeutente as NOMETEI , -- Nome del tecnico ALFANUMERICO (20)
			'' as INDTEC1 , -- Indirizzo ALFANUMERICO 
			'' as NCITEC1 , -- Numero civico ALFANUMERICO
			'' as LOCTEC1 , -- Località di residenza ALFANUMERICO  
			'' as PROTEC  , -- Provincia ALFANUMERICO 
			'' as CAPTEC1 , -- Codice di avviamento postale ALFANUMERICO 
			'' as G_CITTECI , -- Codice ISTAT del comune ALFANUMERICO 
			u.pfuTel as TELTEC1 , -- Numero di telefono ALFANUMERICO 
			'' as FAXTEC1 , -- FAX 
			u.pfuE_Mail as G_EMATECI , -- Indirizzo E-mail ALFANUMERICO 

			'true' as W3PROFILO1 , -- Profilo del committente ( da fare capire )
			'true' as W3MIN1 , -- Sito Informatico Ministero Infrastrutture ( da fare capire )
			'true' as W3OSS1 , -- Sito Informatico Osservatorio Contratti Pubblici ( da fare capire )
			
			s2.ID_STAZIONE_APPALTANTE as W9CCCODICE,
			s2.DENOM_STAZIONE_APPALTANTE as W9CCDENOM,
			cf.vatValore_FV as CFEIN ,
			P.id as idPDA,
			D.id,
			--'8B2B607A-8241-474F-B92C-C9ED51919963'  as W9CCCODICE , -- se presente il SIMOG da recuperare dalla tabella Document_SIMOG_GARA il campo ID_STAZIONE_APPALTANTE
			--'AGENZIA INTERCENT-ER SOGGETTO AGGREGATORE' as W9CCDENOM  , --se presente il SIMOG da recuperare dalla tabella Document_SIMOG_GARA il campo DENOM_STAZIONE_APPALTANTE
			
			s2.DURATA_ACCQUADRO_CONVENZIONE as W9GADURACCQ,

			att.value as AllegatoPerOCP,
			case when d.tipodoc = 'BANDO_SEMPLIFICATO' then b.DataIndizione else d.DataInvio end as W9PBDATAPUBB, --W9PBDATAPUBB  = Nel caso dell’Appalto Specifico è la “data della determina di indizione dell’appalto”  W9PBDATAPR  altrimenti  la data di invio della gara 
			b.DataScadenzaOfferta as  W9PBDATASCAD,

			b.DataIndizione,

			D.datainvio as W9GADPUBB, --(è la data di pubblicazione del bando sul portale, cioè la data invio del bando di SATER). Ok precompilato. ( Aggiungere il campo con la data invio , in realtà dovrebbe essere la pubblicazione sul GUCE )  
			'N' AS W3FLAG_SA,
			
			--case when B.W9GACAM = '1' then 'S' ELSE 'N' end as W9GACAM, 
			--case when B.W9SISMA = '1' then 'S' ELSE 'N' end as W9SISMA,

			B.W9GACAM,
			B.W9SISMA,

			cd1.value as W3NAZ1,
			cd2.value as W3REG1,

			g2.value as W3GUCE1,
			g4.value as W3GURI1,
			g6.value as W3ALBO1,

			B.W9APOUSCOMP,
			B.W3PROCEDUR,
			B.W3PREINFOR,
			B.W3TERMINE,

			--'true' as W3RELAZUNIC
			--KPF 419998 : l'ufficio Adempimenti Trasversali mi ha appena comunicato che nel wscop di interoperabilità con il Sitar il campo "Redatta e disponibile a richiesta la Relazione Unica sulle Procedure di Aggiudicazione" come valore di default deve avere NO anziché SI.
			'false' as W3RELAZUNIC

		from CTL_DOC D with(nolock) 
				inner join document_bando B with(nolock) on D.id = B.idheader
				left join CTL_DOC_VALUE R with(nolock) on R.idheader = D.id and r.DSE_ID = 'InfoTec_comune' and R.DZT_Name = 'UserRUP' 

				left join CTL_DOC_VALUE cd1 with(nolock) on cd1.idheader = D.id and cd1.DSE_ID = 'InfoTec_2comune' and cd1.DZT_Name = 'NumeroQuotNaz' 
				left join CTL_DOC_VALUE cd2 with(nolock) on cd2.idheader = D.id and cd2.DSE_ID = 'InfoTec_2comune' and cd2.DZT_Name = 'NumeroQuotLocali'

				--left join CTL_DOC_VALUE g1 with(nolock) on g1.IdHeader = D.id and g1.dse_id = 'InfoTec_DatePub' and g1.dzt_name = 'Pubblicazioni' and g1.value = '01' --GUCE

				left join (
						select s_g1.idheader, min(s_g1.IdRow) as IdRow
							from CTL_DOC_VALUE s_g1 with(nolock) 
							where s_g1.dse_id = 'InfoTec_DatePub' and s_g1.dzt_name = 'Pubblicazioni' and s_g1.value = '01' --GUCE/GUUE
							group by s_g1.IdHeader
					) min_g1 on min_g1.IdHeader = d.Id

				left join ctl_doc_value g1 with(nolock) on g1.IdRow = min_g1.IdRow

				left join ctl_doc_value g2 with(nolock) on g2.IdHeader = g1.IdHeader and g2.DSE_ID = g1.DSE_ID and g2.row = g1.row and g2.DZT_Name = 'DataPubblicazioneBando'
	
				left join CTL_DOC_VALUE g3 with(nolock) on g3.IdHeader = D.id and g3.dse_id = 'InfoTec_DatePub' and g3.dzt_name = 'Pubblicazioni' and g3.value = '02' --GURI
				left join ctl_doc_value g4 with(nolock) on g4.IdHeader = g3.IdHeader and g4.DSE_ID = g3.DSE_ID and g4.row = g3.row and g4.DZT_Name = 'DataPubblicazioneBando'

				left join CTL_DOC_VALUE g5 with(nolock) on g5.IdHeader = D.id and g5.dse_id = 'InfoTec_2DatePub' and g5.dzt_name = 'Pubblicazioni' and g5.value = '03' --Albo Pretorio Comune
				left join ctl_doc_value g6 with(nolock) on g6.IdHeader = g5.IdHeader and g6.DSE_ID = g5.DSE_ID and g6.row = g5.row and g6.DZT_Name = 'DataPubblicazioneBando'

				left join profiliutente U with(nolock) on U.idpfu = R.Value
			
				left join DM_Attributi cf with(nolock) on cf.lnk = d.Azienda and cf.dztNome = 'codicefiscale' and cf.idApp = 1
				left join ctl_doc P with(nolock) on P.tipodoc = 'PDA_MICROLOTTI' and P.deleted = 0 and P.Linkeddoc = D.Id

				-- collega la procedura alla richiesta CIG del SIMOG se presente
				left join ctl_doc S with(nolock) on S.LinkedDoc = D.id and S.deleted = 0 and s.TipoDoc = 'RICHIESTA_CIG' and S.StatoFunzionale =  'Inviato' 
				left join Document_SIMOG_GARA s2 with(nolock) on s2.idHeader = S.Id

				left join ctl_doc_value att with(nolock) on att.IdHeader = d.id and att.dse_id = 'PARAMETRI' and att.DZT_Name = 'AllegatoPerOCP'

				left join Document_PCP_Appalto pcpa with(nolock) on pcpa.idheader = D.id 
GO
