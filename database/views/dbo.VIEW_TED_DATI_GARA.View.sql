USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_DATI_GARA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[VIEW_TED_DATI_GARA] AS
	select D.id, --id della procedura. chiave di ingresso
			s2.id_gara as [id_gara],
			left(D.Titolo,400) as TED_TITOLO_PROCEDURA_GARA,
			cpv.value as TED_CPV_GARA,

			case when B.TipoAppaltoGara = '2' then 1 --lavori
				 when B.TipoAppaltoGara = '3' then 2 --servizi
				 when B.TipoAppaltoGara = '1' then 3 --forniture
			 end as TED_TIPO_CONTRATTO_APPALTO,

			 --case when b.Divisione_lotti = '0' then NULL else

				-- case when isnull(b.Num_max_lotti_offerti,0) = 0 then 1 --tutti i lotti
				--	  when isnull(b.Num_max_lotti_offerti,0) > 0 then 2 --numero massimo di lotti
				--	  when b.Num_max_lotti_offerti = 1 then 3 --un solo lotto
				--   end 
				--end	as TED_MAX_LOTTI_PARTECIPAZIONE,
			 
			 --att. 555836 sempre vuoto
			 NULL as TED_MAX_LOTTI_PARTECIPAZIONE,

			 case when b.Divisione_lotti = '0' then NULL 
					else 
						case when isnull(b.Num_max_lotti_offerti,0) > 0 then b.Num_max_lotti_offerti end 
			 end as TED_NUM_MAX_LOTTI_PARTECIPAZIONE,

			 case when b.Divisione_lotti = '0' then NULL 
					else
						case when isnull(b.Num_max_lotti_offerti,0) > 0 then b.Num_max_lotti_offerti end 
			 end as TED_NUM_MAX_LOTTI_OFFERENTE,

			 case when b.Divisione_lotti = '0' then NULL else 'N' end as TED_FLAG_SA_AGG_GRUPPI_LOTTI,

			 NULL as TED_APPALTO_CC,
			 sys1.DZT_ValueDef + '/' + sys2.DZT_ValueDef as TED_URL_VERSIONE_ELETTRONICA,
			 dbo.PARAMETRI( 'PORTALE','URL_DOCUMENTI','value','',-1) as TED_URL_DOC_DISPONIBILI,
			 1 as TED_INFO_AGGIUNTIVE,
			 case when b.TipoBandoGara = '3' or d.TipoDoc = 'BANDO_SEMPLIFICATO' then 2 else 1 end as TED_DOCUMENTI_DISPONIBILI,
			 --3 as TED_TIPO_AMM_AGG, --aspettiamo dal cliente una trascodifica rispetto al nostro TIPO_AMM_ER
			 
			 --dbo.TED_GET_TIPO_AMM_AGG( dm3.vatValore_FT ) as TED_TIPO_AMM_AGG,

			 '' as TED_TIPO_AMM_AGG,

			 dm1.vatValore_FT as TED_SETTORE_PRINCIPALE,
			 case when dm1.vatValore_FT <> '11' then '' else dm2.vatValore_FT end as TED_ALTRO_SETTORE_PRINCIPALE,
			 null as TED_APPALTO_RINNOVABILE, 
			 null as TED_TEMPO_STIMATO_PROSSIMI_BANDI,
			 null as TED_ORDINATIVO_ELETTRONICO,
			 null as TED_FATTURAZIONE_ELETTRONICA,
			 null as TED_PAGAMENTI_ELETTRONICI, 
			 null as TED_INFO_ADD,
			 null as TED_REVIEW_PROCEDURE,

			 null as TED_ELENCO_CONDIZIONI,
			 'S' as TED_CRITERI_ECONOMICI,
			 'S' as TED_CRITERI_TECNICI,
			 null as TED_INTEGRAZIONE_DISABILI,
			 null as TED_LAVORI_PROTETTI,
			 null as TED_FLAG_PROFESSIONE_SERVIZI,
			 null as TED_PROFESSIONE_SERVIZI,
			 null as TED_CONDIZIONI_ESECUZIONE_CONTRATTO,
			 null as TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO,

			 --case when b.ProceduraGara = 15476 then 1 -- 1-Procedura aperta
				--  when b.ProceduraGara = 15477 then 2 -- 2-Procedura ristretta
				--  when b.ProceduraGara = 15478 or b.ProceduraGara = 15479 then 3 -- 3-Procedura competitiva con negoziazione				
				--	-- Non abbiamo una controparte in sater per questi due valori quindi lasciamo il campo a video editabile :  
				--	--	4-Dialogo competitivo
				--	--	5-Paternario per l'innovazione
				--end as TED_TIPO_PROCEDURA,

			dbo.TED_GET_TIPO_PROCEDURA( s2.ID_SCELTA_CONTRAENTE ) as TED_TIPO_PROCEDURA,

			'N' as TED_FLAG_PROCEDURA_ACCELLERATA,
			null as TED_TIPO_OPERATORI_AQ,
			null as TED_NUM_MAX_PARTECIPANTI_AQ,
			null as TED_ALTRI_ACQUIRENTI_SIS_DINAMICO,
			null as TED_NOTE_AQ_QUATTRO_ANNI,
			'N' as TED_REDUCTION_RECOURSE,
			null as TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE,
			null as TED_NOTE_ASTA_ELETTRONICA,
			null as TED_FLAG_APP,
			null as TED_PERIODO_VALIDITA_OFFERTE,
			null as TED_MESI_VALIDITA_OFFERTE,
			b.DataAperturaOfferte as TED_DATA_APERTURA_OFFERTE,
			sys1.DZT_ValueDef + '/' + sys2.DZT_ValueDef as TED_LUOGO_APERTURA_OFFERTE,
			null as TED_PERSONE_APERTURA_OFFERTE
		from CTL_DOC D with(nolock) 
				inner join document_bando B with(nolock) on D.id = B.idheader
				--left join CTL_DOC_VALUE R with(nolock) on R.idheader = D.id and r.DSE_ID = 'InfoTec_comune' and R.DZT_Name = 'UserRUP' 
				left join ctl_doc_value cpv with(nolock) on cpv.idheader = D.id and cpv.dse_id = 'InfoTec_SIMOG' and cpv.dzt_name = 'CODICE_CPV' 
				-- collega la procedura alla richiesta CIG del SIMOG se presente
				left join ctl_doc S with(nolock) on S.LinkedDoc = D.id and S.deleted = 0 and s.TipoDoc = 'RICHIESTA_CIG' and S.StatoFunzionale =  'Inviato' 
				left join Document_SIMOG_GARA s2 with(nolock) on s2.idHeader = S.Id

				left join LIB_Dictionary sys1 with(nolock) on sys1.DZT_Name = 'SYS_WEBSERVERPORTALE'
				left join LIB_Dictionary sys2 with(nolock) on sys2.DZT_Name = 'SYS_NOMEAPPPORTALE_JOOMLA'

				left join DM_Attributi dm1 with(nolock) on dm1.lnk = d.Azienda and dm1.idApp = 1 and dm1.dztNome = 'TED_SETTORE_PRINCIPALE' -- viene salvato il campo del ted SETTORE_PRINCIPALE sulla dm_attributi dell'ente appaltante dopo l'invio della prima richiesta
				left join DM_Attributi dm2 with(nolock) on dm2.lnk = d.Azienda and dm2.idApp = 1 and dm2.dztNome = 'TED_ALTRO_SETTORE_PRINCIPALE' -- viene salvato il campo del ted SETTORE_PRINCIPALE sulla dm_attributi dell'ente appaltante dopo l'invio della prima richiesta
				
				--left join DM_Attributi dm3 with(nolock) on dm3.lnk = d.Azienda and dm3.idApp = 1 and dm3.dztNome = 'TIPO_AMM_ER'

GO
