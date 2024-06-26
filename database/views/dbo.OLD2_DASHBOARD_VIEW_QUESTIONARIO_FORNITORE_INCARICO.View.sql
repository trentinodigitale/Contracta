USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_QUESTIONARIO_FORNITORE_INCARICO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_QUESTIONARIO_FORNITORE_INCARICO]  AS

		select 

			a.id as idmsg,
			isnull(CTL_DOC_DESTINATARI.IdPfu,-1) as IdPfu,
			-1 as msgIType,
			-1 as msgIsubType,
			a.titolo as Oggetto,
			a.data,

			a.Protocollo as ProtocolloBando,
			--Protocollo as ProtocolloOfferta,
			a.DataScadenza as ReceidevDataMsg,
			--cast(Body as nvarchar (2000)) as Oggetto,
			'' as Tipologia,
			a.DataScadenza AS ExpiryDate,
			'' as ImportoBaseAsta,
			'' as tipoprocedura,
			'' as StatoGd,
			a.Fascicolo,
			'' as CriterioAggiudicazione,
			'' as CriterioFormulazioneOfferta
			,'1' as OpenDettaglio
			,0 as Scaduto
			,'QUESTIONARIO_FORNITORE' as OPEN_DOC_NAME ,
			a.statofunzionale,
			p.aziragionesociale as ragsoc,
			p.idazi,
			p.idazi as idazi2,
			b.id as idbando

			,case when l.DOC_NAME is not null then '0' else '1'end as bRead 

			,isnull(CTL_DOC_DESTINATARI.IdPfu,-1) as owner
			, AreaValutazione 

				from CTL_DOC a with (nolock)
					left outer join CTL_DOC_DESTINATARI with (nolock) on CTL_DOC_DESTINATARI.idheader=a.Id
					--cross join dm_attributi 
					inner join aziende p with (nolock) on  p.idazi=azienda
					left outer join ctl_doc b with (nolock) on  b.id=a.LinkedDoc and b.tipodoc in ('bando','bando_qf')

					left outer join CTL_DOC_READ as l  with(NOLOCK) on isnull(CTL_DOC_DESTINATARI.IdPfu,-1)=l.idpfu and a.id=l.id_Doc 
							and l.DOC_NAME = 'QUESTIONARIO_FORNITORE'
					left outer join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi x with(NOLOCK) on x.idHeader = a.id


						where a.TipoDoc='QUESTIONARIO_FORNITORE'
							and a.deleted=0
							and a.statofunzionale='InCarico'
--and idapp=1 and dztnome='AttivazioneValutazione'
--		  and vatvalore_ft='10099'














GO
