USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_BANDOUNICO_ONLY_INAPPROVE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_BANDOUNICO_ONLY_INAPPROVE]
AS
	SELECT ww.*,
		  pfua.IdPfu AS Owner ,
		  '' as OPEN_DOC_NAME,
		  APS_Idpfu as idpfuincharge,
		  '' as TipoSceltaContraente
		  , 'NO' as Cottimo_Gara_Unificato
	    from
		(
			
			select 
				p.* ,
				case 
					--when (RIGHT(p.ProtocolloBando, 2) = '07'  and p.ProtocolloBando <> '053/2007') 
					--	or p.ProtocolloBando = '006/2008'  THEN 'Archiviato'
					when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'

					else r.StatoRepertorio 

				end as StatoRepertorio 
				    
				, case t.visualizzanotifiche
					when '1' then t.ReceivedOff
					when '0' then
						case 
							--when getdate() > t.DataAperturaOfferte then t.ReceivedOff
							when getdate() > ISNULL(NULLIF(t.expirydate, 'T00:00:00'), '') then t.ReceivedOff
							else ''
						end
					end as ReceivedOff   

				
				from 
				(

					SELECT z.IdMsg
						 , umIdPfu AS IdPfu
						 , msgIType
						 , msgISubType
						 , msgelabwithsuccess
						
						 ,t.Name
						
						 ,t.Object_Cover1 as Oggetto
						
						 ,t.ProtocolloBando
						
						 ,t.ExpiryDate
						
						 ,case t.ImportoBaseAsta WHEN '0' then NULL
								else t.ImportoBaseAsta
						   end as ImportoBaseAsta
						
						 ,case t.CriterioAggiudicazioneGara WHEN '0'then ''
								else t.CriterioAggiudicazioneGara
						   end as CriterioAggiudicazioneGara
						 
						 --, SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 1) AS StatoGD
						 , t.Stato AS StatoGD
						 ,t.FaseGara
						, t.Protocol as Protocollo
						, '' as TipoProceduraCaratteristica
						 
					  FROM TAB_MESSAGGI as z with(nolock) 
						 , TAB_UTENTI_MESSAGGI with(nolock) 
						 ,TAB_MESSAGGI_FIELDS as t with(nolock) 
						
					 WHERE z.IdMsg = umIdMsg
					   AND msgItype = 55
					   AND msgisubtype in (167,34,20,48,78,68,24)
					   AND umInput = 0
					   AND umStato = 0
					   AND umIdPfu <> -10
						and T.IdMsg = z.IdMsg 

				) as p
				left outer join Document_Repertorio r  with(nolock) on r.ProtocolloBando = p.ProtocolloBando
				inner join TAB_MESSAGGI_FIELDS t  with(nolock) on p.idmsg=t.idmsg

        ) as ww
	
		INNER JOIN CTL_ApprovalSteps ctas  with(nolock) ON ww.IdMsg = ctas.APS_Id_Doc 
															AND ctas.APS_State =  'InCharge' 
															AND ctas.APS_Doc_Type = 'APPROVAZIONE' 
														 -- AND ctas.APS_IdPfu = ''
		INNER JOIN ProfiliUtenteAttrib pfua  with(nolock) on ctas.APS_UserProfile = pfua.attValue AND pfua.dztNome = 'UserRole'
		INNER JOIN ProfiliUtente pfu  with(nolock) ON pfua.IdPfu = pfu.IdPfu


union all

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
				
				, C.Cottimo_Gara_Unificato

			from CTL_DOC  d  with(nolock) 
				inner join dbo.Document_Bando DB with(nolock)  on id = DB.idheader
				inner join CTL_ApprovalSteps s  with(nolock) on tipodoc = APS_Doc_Type and APS_State = 'InCharge' and APS_ID_DOC = d.id and APS_IsOld=0
				
				-- recupero l'utente dal ruolo solamente se non è indicato in modo specifico 
				left outer join profiliutenteattrib a  with(nolock) on isnull( APS_IdPfu , '' ) = '' and dztNome = 'UserRole' and APS_UserProfile = attValue
				
				--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
				cross join (select dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 ) as Cottimo_Gara_Unificato ) C  

			where deleted = 0 and TipoDoc in ( 'BANDO_GARA' ) 
GO
