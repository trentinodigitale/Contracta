USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COMUNICAZIONI_ENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--Versione=4&data=2014-04-23&Attvita=54963&Nominativo=Enrico
CREATE VIEW [dbo].[DASHBOARD_VIEW_COMUNICAZIONI_ENTE]
AS
SELECT			
				 IdCom
				 , Name
				  ,'' as Fascicolo
				 , 0 as bRead 
				 , owner
				 , convert(varchar(30),DataCreazione,121) as DataCreazione
				 , Protocollo
				 , 'COM_DPE' as OPEN_DOC_NAME
				 , '2' AS StatoGD
				 , '1' as OpenDettaglio
				 , 0 as LinkedDoc
				 ,'' as StatoDoc
				 , '' as jumpcheck
			  FROM 
					Document_Com_DPE 
			   where 
					StatoCom <> 'Salvato'  
					AND Deleted = 0

			union 

			SELECT 
			  IdMsg as IdCom
			  , Name  
			  ,protocolbg as Fascicolo
			  ,[Read] AS bRead  
			  , umIdPfu  AS owner
			  ,	case 
						when len(ReceivedDataMsg)<10 then ''
						else  ReceivedDataMsg
					end  as  DataCreazione

			  , ProtocolloOfferta AS Protocollo
			  , 'DOCUMENTO_GENERICO' as OPEN_DOC_NAME
			  , rtrim(ltrim(stato)) AS StatoGD
			  , '1' as OpenDettaglio
			  , 0 as LinkedDoc
			  ,'' as StatoDoc
              , '' as jumpcheck
			FROM 
			document,  
			tab_utenti_messaggi, 
		    TAB_MESSAGGI_FIELDS 
			WHERE  umIdMsg = IdMsg  
			 and IType = dcmIType  
			 and ISubType = dcmISubType  
			 and dcmDeleted = 0  
			 and ISubType in ( 96 , 83, 108)
			 and uminput=0
			 and umstato=0
			 --and protocolbg='FE000211'
			

			union 

			SELECT C.ID as IdCom
				 , C.Titolo as Name
				 , C.Fascicolo
				 , case when r.id is null then 1 else 0 end as bRead 
				 , c.IdPfu AS owner
				 , convert(varchar(30),C.DataInvio ,121) as DataCreazione
				 , C.Protocollo
				 ,TipoDoc as OPEN_DOC_NAME
			  ,  case 
					when StatoDoc='Saved' then '1'
					when StatoDoc='Sended' then '2'
					when StatoDoc='Invalidate' then '4'
					else  '2'
				end AS StatoGD
			  , '1' as OpenDettaglio
			  , LinkedDoc
			  , StatoDoc
              , isnull(jumpcheck,'') as jumpcheck
			  FROM CTL_DOC C 
				left outer join ctl_doc_read r on c.id = r.id_doc 
												and DOC_NAME in ('PDA_COMUNICAZIONE','PDA_COMUNICAZIONE_OFFERTA','VERBALEGARA')
												and r.idpfu = c.idpfu
			 WHERE 
				--C.StatoDoc <> 'Saved'  
			    C.Deleted = 0 and TipoDoc in ('PDA_COMUNICAZIONE','PDA_COMUNICAZIONE_OFFERTA','PDA_COMUNICAZIONE_GENERICA','VERBALEGARA','RETTIFICA_GARA' ,'PROROGA_GARA')



			UNION
			--le comunicazioni di esito e svincolo
			SELECT 
				 C.ID as IdCom
				 , C.Titolo as Name
				 , TM.protocolbg as Fascicolo
				 , case when r.id is null then 1 else 0 end as bRead 
				 , c.IdPfu                           AS owner
				 , convert(varchar(30),C.DataInvio ,121) as DataCreazione
				 , C.Protocollo
				 , 'ESITO_GARA' as OPEN_DOC_NAME
				 ,  case 
						when C.StatoEsclusione='Saved' then '1'
						else  '2'
					end AS StatoGD
				 , '1' as OpenDettaglio
			     , 0 as LinkedDoc
				 ,'' as StatoDoc
                 , '' as jumpcheck
				FROM Document_EsitoGara C inner join
				tab_messaggi_fields TM  on TM.idmsg=C.id_msg_bando
				left outer join ctl_doc_read r on c.id = r.id_doc 
												and DOC_NAME in ('ESITO_GARA')
												and r.idpfu = c.idpfu

			     
			UNION
			--le com di aggiufdicazione
			select 
				C.id,
				C.Titolo
				, TM.protocolbg as Fascicolo
				, case when r.id is null then 1 else 0 end as bRead
				,C.IdPfu
				, convert(varchar(30),C.DataInvio ,121) as DataCreazione
				,C.Protocollo
				, 'COM_AGGIUDICATARIA' as OPEN_DOC_NAME
				,  case 
						when C.Stato='Saved' then '1'
						else  '2'
					end AS StatoGD
				 , '1' as OpenDettaglio
			     , 0 as LinkedDoc
				 ,'' as StatoDoc
                 , '' as jumpcheck
			from Document_Com_Aggiudicataria C
			inner join tab_messaggi_fields TM  on TM.idmsg=C.id_msg_bando
			left outer join ctl_doc_read r on c.id = r.id_doc 
							and DOC_NAME in ('COM_AGGIUDICATARIA')
							and r.idpfu = c.idpfu



GO
