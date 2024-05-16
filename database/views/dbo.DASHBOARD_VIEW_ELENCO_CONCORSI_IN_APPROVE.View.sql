USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ELENCO_CONCORSI_IN_APPROVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[DASHBOARD_VIEW_ELENCO_CONCORSI_IN_APPROVE]
AS
	select 
	
				 d.id as IdMsg
				 , d.idpfu 
				 , 0 as msgIType
				 , 0 as msgISubType
				 , -1 as msgelabwithsuccess
				
				 ,D.Titolo as Name
				
				 ,cast( d.Body as nvarchar(2000)) as Oggetto
				
				 , ProtocolloBando
				
				 ,db.DataScadenzaOfferta as ExpiryDate
				
				 ,case db.ImportoBaseAsta WHEN '0' then NULL
				        else db.ImportoBaseAsta
				   end as ImportoBaseAsta
				
				 ,case db.CriterioAggiudicazioneGara WHEN '0'then ''
				        else db.CriterioAggiudicazioneGara
				   end as CriterioAggiudicazioneGara
				 
				 , 1 AS StatoGD
				 , '' as FaseGara
	

				
				, d.Protocollo
				, isnull( TipoProceduraCaratteristica , '' ) as TipoProceduraCaratteristica
				, '' as StatoRepertorio 
				, '' as ReceivedOff   
				
				,case when isnull( APS_IdPfu , '' ) = '' 
						then a.idpfu
						else cast( APS_IdPfu as int ) 
					end as Owner
				, tipoDoc + '_IN_APPROVE' as OPEN_DOC_NAME
				,APS_Idpfu as idpfuincharge

				,isnull(TipoSceltaContraente,'') as TipoSceltaContraente

			from CTL_DOC  d  with(nolock) 
				inner join dbo.Document_Bando DB with(nolock)  on id = DB.idheader
				inner join CTL_ApprovalSteps s  with(nolock) on tipodoc = APS_Doc_Type and APS_State = 'InCharge' and APS_ID_DOC = d.id and APS_IsOld=0
				
				-- recupero l'utente dal ruolo solamente se non è indicato in modo specifico 
				left outer join profiliutenteattrib a  with(nolock) on isnull( APS_IdPfu , '' ) = '' and dztNome = 'UserRole' and APS_UserProfile = attValue

			where deleted = 0 and TipoDoc in ( 'BANDO_CONCORSO' ) 
GO
