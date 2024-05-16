USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_QUESTIONARIO_FORNITORE_VALUTATO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[DASHBOARD_VIEW_QUESTIONARIO_FORNITORE_VALUTATO]  AS

	select 

		id as idmsg,
		isnull(CTL_DOC_DESTINATARI.IdPfu,-1) as IdPfu,
		-1 as msgIType,
		-1 as msgIsubType,
		titolo as Oggetto,
		data,
		'' as bread,
		Protocollo as ProtocolloBando,
		--Protocollo as ProtocolloOfferta,
		DataScadenza as ReceidevDataMsg,
		--cast(Body as nvarchar (2000)) as Oggetto,
		'' as Tipologia,
		DataScadenza AS ExpiryDate,
		'' as ImportoBaseAsta,
		'' as tipoprocedura,
		'' as StatoGd,
		Fascicolo,
		'' as CriterioAggiudicazione,
		'' as CriterioFormulazioneOfferta
		,'1' as OpenDettaglio
		,0 as Scaduto
		,'QUESTIONARIO_FORNITORE' as OPEN_DOC_NAME ,
		statofunzionale,
		p.aziragionesociale as ragsoc,
		p.idazi,
		p.idazi as idazi2
		,LinkedDoc as idbando
		, AreaValutazione ,
		IsTestata as TipoQuestionario



			from CTL_DOC with (nolock)
				left outer join CTL_DOC_DESTINATARI with (nolock) on CTL_DOC_DESTINATARI.idheader=ctl_doc.Id
				--cross join dm_attributi 
				inner join aziende p with (nolock) on  p.idazi=azienda
				left outer join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi x with(NOLOCK) on x.idHeader = id

					where TipoDoc='QUESTIONARIO_FORNITORE'
						and deleted=0
						and statofunzionale='Valutato'
--and idapp=1 and dztnome='AttivazioneValutazione'
--		  and vatvalore_ft='10099'













GO
