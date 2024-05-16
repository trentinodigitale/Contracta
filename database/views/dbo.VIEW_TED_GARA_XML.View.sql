USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_GARA_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_TED_GARA_XML] AS
	select g.idHeader, --chiave di ingresso

			--attributi della radice deltaGaraTED
			g.TED_APPALTO_CC,
			cast(g.TED_DOCUMENTI_DISPONIBILI as varchar) as TED_DOCUMENTI_DISPONIBILI,
			g.TED_URL_DOC_DISPONIBILI,
			cast(g.TED_INFO_AGGIUNTIVE as varchar) as TED_INFO_AGGIUNTIVE,
			g.TED_URL_VERSIONE_ELETTRONICA,
			cast(g.TED_TIPO_AMM_AGG as varchar) as TED_TIPO_AMM_AGG,
			cast(g.TED_SETTORE_PRINCIPALE as varchar) as TED_SETTORE_PRINCIPALE,
			g.TED_ALTRO_SETTORE_PRINCIPALE,
			
			--attributi del tag ENTITA_APPALTO
			g.TED_TITOLO_PROCEDURA_GARA,
			isnull(cpv.DMV_CodExt,'') as TED_CPV_GARA,
			cast(g.TED_TIPO_CONTRATTO_APPALTO as varchar) as TED_TIPO_CONTRATTO_APPALTO,
			cast(g.TED_MAX_LOTTI_PARTECIPAZIONE as varchar) as TED_MAX_LOTTI_PARTECIPAZIONE,
			cast(g.TED_NUM_MAX_LOTTI_PARTECIPAZIONE as varchar) as TED_NUM_MAX_LOTTI_PARTECIPAZIONE,
			cast(g.TED_NUM_MAX_LOTTI_OFFERENTE as varchar) as TED_NUM_MAX_LOTTI_OFFERENTE,
			cast(g.TED_FLAG_SA_AGG_GRUPPI_LOTTI as varchar) as TED_FLAG_SA_AGG_GRUPPI_LOTTI,

			---attributi del tag DATI_AMM_AGGIUDICATRICE
			a.TED_OFFICIALNAME,
			a.TED_NATIONALID,
			a.TED_ADDRESS,
			a.TED_TOWN,
			a.TED_NUTS,
			a.TED_POSTAL_CODE,
			a.TED_COUNTRY,
			a.TED_CONTACT_POINT,
			dbo.TED_CONVERT_PHONE_NUMBER(a.TED_PHONE,0) as TED_PHONE,
			dbo.TED_CONVERT_PHONE_NUMBER(a.TED_FAX,0) as TED_FAX,
			a.TED_E_MAIL,
			a.TED_URL_GENERAL,
			a.TED_URL_BUYER,

			--attributi del tag ALTRE_INFO
			g.TED_APPALTO_RINNOVABILE,
			g.TED_TEMPO_STIMATO_PROSSIMI_BANDI,
			g.TED_ORDINATIVO_ELETTRONICO,
			g.TED_FATTURAZIONE_ELETTRONICA,
			g.TED_PAGAMENTI_ELETTRONICI,
			g.TED_INFO_ADD,
			g.TED_REVIEW_PROCEDURE,

			--attributi del tag ORGANISMO_RICORSO
			M.TED_OFFICIALNAME as OFFICIALNAME,
			M.TED_ADDRESS as [ADDRESS],
			M.TED_TOWN as TOWN,
			M.TED_POSTAL_CODE as POSTAL_CODE,
			M.TED_COUNTRY as COUNTRY,
			dbo.TED_CONVERT_PHONE_NUMBER(M.TED_PHONE,0) as PHONE,
			dbo.TED_CONVERT_PHONE_NUMBER(M.TED_FAX,0) as FAX,
			M.TED_E_MAIL as E_MAIL,
			M.TED_URL_SA as URL_SA,

			--attributi del tag CONDIZIONI_PARTECIPAZIONE
			g.TED_ELENCO_CONDIZIONI,
			g.TED_CRITERI_ECONOMICI,
			g.TED_CRITERI_TECNICI,
			g.TED_INTEGRAZIONE_DISABILI,
			g.TED_LAVORI_PROTETTI,
			g.TED_FLAG_PROFESSIONE_SERVIZI,
			g.TED_PROFESSIONE_SERVIZI,
			g.TED_CONDIZIONI_ESECUZIONE_CONTRATTO,
			g.TED_OBBLIGO_NOMI_ESECUZIONE_CONTRATTO,

			--attributi del tag DATI_PROCEDURA
			cast(g.TED_TIPO_PROCEDURA as varchar) as TED_TIPO_PROCEDURA,
			g.TED_FLAG_PROCEDURA_ACCELLERATA,
			cast(g.TED_TIPO_OPERATORI_AQ as varchar) as TED_TIPO_OPERATORI_AQ,
			cast( g.TED_NUM_MAX_PARTECIPANTI_AQ as varchar) as TED_NUM_MAX_PARTECIPANTI_AQ,
			g.TED_ALTRI_ACQUIRENTI_SIS_DINAMICO,
			g.TED_NOTE_AQ_QUATTRO_ANNI,
			g.TED_REDUCTION_RECOURSE,
			--KPF 498952  per prevenire errore SERVICE_ERROR_042b – Facoltà di aggiudicare senza negoziazione – campo non richiesto 
			--Non richiesto se la procedura non è competitiva con negoziazione (H0!=3) lo lasciamo vuoto
			case when g.TED_TIPO_PROCEDURA <> '3' then NULL else g.TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE end as  TED_AGGIUDICAZIONE_SENZA_NEGOZIAZIONE,
			g.TED_NOTE_ASTA_ELETTRONICA,
			g.TED_FLAG_APP,

			--attributi del tag INFO_AMMINISTRATIVE
			CONVERT(varchar(10),g.TED_PERIODO_VALIDITA_OFFERTE, 121) as TED_PERIODO_VALIDITA_OFFERTE,
			cast(g.TED_MESI_VALIDITA_OFFERTE as varchar) as TED_MESI_VALIDITA_OFFERTE,
			isnull(CONVERT(varchar(10), g.TED_DATA_APERTURA_OFFERTE, 121),'') as TED_DATA_APERTURA_OFFERTE,
			isnull(CONVERT(varchar(5), g.TED_DATA_APERTURA_OFFERTE, 108),'') as TED_ORA_APERTURA_OFFERTE,
			g.TED_LUOGO_APERTURA_OFFERTE,
			g.TED_PERSONE_APERTURA_OFFERTE

		from Document_TED_GARA g with(nolock)
				inner join Document_TED_AMMINISTRAZIONE a with(nolock) on a.idHeader = g.idHeader

				left join LIB_DomainValues cpv with(nolock) on cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = g.TED_CPV_GARA

				inner join (
							select * from 
								(
									select idheader,  row, value, dzt_name
									from CTL_DOC_Value  with(nolock)
									where dse_id = 'GARA_SEZ_6_2'
        						) as P
								pivot
								(
									min(value) for p.dzt_name in ([TED_OFFICIALNAME],
														[TED_ADDRESS],
														[TED_TOWN],
														[TED_POSTAL_CODE],
														[TED_COUNTRY],
														[TED_PHONE],
														[TED_FAX],
														[TED_E_MAIL],
														[TED_URL_SA] )
								) as PIV
							) as M on M.idheader = g.idHeader 

GO
