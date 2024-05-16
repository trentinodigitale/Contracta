USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI_QF]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI_QF]  AS

	select 

			CTL_DOC.id as idmsg,
			p.IdPfu,
			-1 as msgIType,
			-1 as msgIsubType,
			titolo as Name,
			ProtocolloGenerale as ProtocolloBando,
			Protocollo as ProtocolloOfferta,
			DataScadenza as ReceidevDataMsg,
			cast(Body as nvarchar (2000)) as Oggetto,
			'' as Tipologia,
			--DataScadenza AS ExpiryDate,
			'' as ImportoBaseAsta,
			'' as tipoprocedura,
			'' as StatoGd,
			Fascicolo,
			'' as CriterioAggiudicazione,
			'' as CriterioFormulazioneOfferta
			,'1' as OpenDettaglio,Protocollo,

			CASE 
				WHEN DataScadenza is null THEN 0
				WHEN isnull(DataScadenza,convert(varchar(19), GETDATE(),126)) > convert(varchar(19), GETDATE(),126) THEN 0
				ELSE 1
			  END AS Scaduto	

			  

			,'BANDO_FORN_QF' as OPEN_DOC_NAME 
			,'' as AttivazioneValutazione,
			dbo.GetStatoQuestionario(CTL_DOC.id,getdate(),x.idazi) as  StatoQuestionario,
			dbo.GetDataScadQuestionario(CTL_DOC.id,x.idazi) as ExpiryDate,
			dbo.GetStatoAbilitazioneQuestionario(CTL_DOC.id,x.idazi) as StatoAbilitazione,
			CTL_DOC.id as idbando,
			CTL_DOC.id as id
			,case when l.DOC_NAME is not null then '0' else '1'end as bRead 

	from CTL_DOC

			left outer join CTL_DOC_DESTINATARI on CTL_DOC_DESTINATARI.idheader=CTL_DOC.Id
			-- il bando deve essere visto da tutti i fornitori non cancellati
			cross join aziende x
			inner join profiliutente p on  p.pfuidazi = x.idazi

			left outer join CTL_DOC_READ as l  with(NOLOCK) on p.idpfu=l.idpfu and CTL_DOC.id=l.id_Doc 
					and l.DOC_NAME = 'BANDO_FORN_QF'

		where TipoDoc='BANDO_QF'
					  --and idapp=1 
					  --and dztnome='AttivazioneValutazione'
					  --and vatvalore_ft='10099'
					  and deleted=0
					  and statofunzionale = 'Pubblicato'
					  and aziVenditore<>0
					  and aziDeleted =0












GO
