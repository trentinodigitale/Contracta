USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI_PUBB]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI_PUBB]  AS

	select 

			id as idmsg,
			IdPfu,
			-1 as msgIType,
			-1 as msgIsubType,
			titolo as Name,
			'' as bread,
			ProtocolloGenerale as ProtocolloBando,
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


			--, CASE CriterioFormulazioneOfferte
			 --           WHEN '' THEN ''
			--			ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
			 --     END AS CriterioFormulazioneOfferta
			,'1' as OpenDettaglio

			 
			-- , CASE 
			--		WHEN DataScadenza is null THEN '0'
			--		ELSE '1'
			--	  END AS Scaduto
			--,0 as Scaduto
			,CASE 
				WHEN DataScadenza is null THEN '0'
				WHEN isnull(DataScadenza,convert(varchar(19), GETDATE(),126)) > convert(varchar(19), GETDATE(),126) THEN '0'
				ELSE '1'
			  END AS Scaduto	
			,'BANDO' as OPEN_DOC_NAME 
			--, StatoIscrizione
			,isnull(jumpcheck,'') as JumpCheck
		
		from CTL_DOC WITH (NOLOCK)	
			inner join dbo.Document_Bando  b WITH (NOLOCK)  on CTL_DOC.Id = b.idheader		
			left  join (Select distinct(linkedDoc) from ctl_doc  WITH (NOLOCK) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO') and statofunzionale = 'Approved' ) V on V.LinkedDoc=CTL_DOC.id		
			where TipoDoc='BANDO'
				and statofunzionale not in ('InLavorazione' , 'InApprove') 
				and deleted=0








GO
