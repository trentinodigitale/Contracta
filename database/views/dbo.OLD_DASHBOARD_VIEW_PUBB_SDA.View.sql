USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PUBB_SDA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_PUBB_SDA] as
select 

		id as idmsg,
		id ,
		IdPfu,
		-1 as msgIType,
		-1 as msgIsubType,
		titolo as Name,
		'' as bread,
		ProtocolloGenerale ,
		ProtocolloBando,
		Protocollo as ProtocolloOfferta,
		DataScadenza as ReceidevDataMsg,
			case
				 when statofunzionale = 'revocato' then '<strong>Bando Revocato - </strong> ' + cast(Body as nvarchar (2000)) 
				 when statofunzionale = 'InRettifica' then '<strong>Bando In Rettifica - </strong> ' + cast(Body as nvarchar (2000)) 
			else
				case when isnull(v.linkeddoc,0) > 0
					 then '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
				else
					cast( Body as nvarchar(4000)) 
				end				
			end as Oggetto,
		'' as Tipologia,
		DataScadenza AS ExpiryDate,
		'' as ImportoBaseAsta,
		'' as tipoprocedura,
		'' as StatoGd,
		Fascicolo,
		'' as CriterioAggiudicazione,
		'' as CriterioFormulazioneOfferta
		,'1' as OpenDettaglio
		,CASE 
			WHEN DataScadenza is null THEN '0'
			WHEN isnull(DataScadenza,convert(varchar(19), GETDATE(),126)) > convert(varchar(19), GETDATE(),126) THEN '0'
			ELSE '1'
		  END AS Scaduto		
		,'BANDO_SDA' as OPEN_DOC_NAME 
		,StatoFunzionale

	from CTL_DOC with(nolock)
		inner join dbo.Document_Bando with(nolock) on id = idheader
		left  join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO') and statofunzionale = 'Approved' ) V on V.LinkedDoc=CTL_DOC.id
	where TipoDoc='BANDO_SDA' 
		and StatoFunzionale in ( 'Pubblicato' , 'InRettifica' ,'Revocato')
		and deleted=0


GO
