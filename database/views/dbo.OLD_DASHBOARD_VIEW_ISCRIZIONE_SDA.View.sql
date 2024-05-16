USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ISCRIZIONE_SDA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_ISCRIZIONE_SDA]  AS
	select 

			id as idmsg,
			p.IdPfu,
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
			, StatoIscrizione
			

		from CTL_DOC
			inner join dbo.Document_Bando b on CTL_DOC.Id = b.idheader
			inner join CTL_DOC_DESTINATARI on CTL_DOC_DESTINATARI.idheader=CTL_DOC.Id
			inner join profiliutente p on  p.pfuidazi = CTL_DOC_DESTINATARI.IdAzi
			left  join (Select distinct(linkedDoc) from ctl_doc where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO') ) V on V.LinkedDoc=CTL_DOC.id
		where TipoDoc='BANDO_SDA'

			and CTL_DOC.deleted = 0  and StatoFunzionale not in ('InApprove','InLavorazione')






GO
