USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_LINKED_DOCUMENTI_INDIRETTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE VIEW [dbo].[MSG_LINKED_DOCUMENTI_INDIRETTI]  AS
--Versione=5&data=2014-01-29&Attivita=52230&Nominativo=enrico
--Versione=6&data=2014-02-27&Attivita=53377&Nominativo=enrico
--Versione=7&data=2015-02-26&Attivita=70503&Nominativo=enrico

--OFFERTE/DOMANDE A CUI PARTECIPO INDIRETTAMENTE
--SELECT 
--     TMF.IdMsg
--     , PO.IdPfu AS IdPfu
--     , TMF.IType
--     , TMF.ISubType  as msgisubtype  
--      ,TMF.name  AS Name	
--      ,TMF.[Read] AS bRead       
--      ,TMF.[Object] AS Oggetto        
--      ,TMF.ProtocolloBando AS ProtocolloBando     
--      ,TMF.ProtocolBG AS Fascicolo        
--      ,TMF.ProtocolloOfferta AS ProtocolloOfferta 	      
--      ,ltrim(rtrim(TMF.Stato)) AS StatoGD
--      ,TMF.AdvancedState AS AdvancedState           
--      ,TMF.ReceivedDataMsg  AS ReceivedDataMsg   
--      ,TMF.IdMittente AS IdMittente 	        
--      ,TMF.ECONOMICA_ENCRYPT as Cifratura
--      ,'' as azipartitaiva
--      ,'' as idAziPartecipante --a.idazi as idAziPartecipante
--	  , 'MESSAGE_' + CAST( TMF.IType AS VARCHAR ) + '_' + cast( TMF.ISubType as varchar ) as DocType ,
	 
--	  case  TMF.Stato 
--		WHEN 1 THEN 'Saved'
--		WHEN 4 THEN 'Invalidate'
--		WHEN 2 then
			
--			CASE TMF.AdvancedState
--				WHEN 0 THEN
					
--					case TMF.ISubType 
--						when '168' then 'Received'
--						else 'Sended'
--					end   
				
--				ELSE
					
--					case TMF.AdvancedState
--						WHEN '' THEN
--							case TMF.ISubType 
--								when '168' then 'Received'
--								else 'Sended'
--							end  
						
--						WHEN 1 THEN 'Confirmed'
--						WHEN 2 THEN 'Rejected'
--						WHEN 3 THEN 'Revoke'
--						WHEN 4 THEN 'InApprove'
--						WHEN 5 THEN 'NotApprove'
--						WHEN 6 THEN 'Correct'
--						WHEN 7 THEN 'Revoke2'
--						WHEN 0 THEN
							
--							case TMF.AuctionState
--								WHEN 0 THEN
--									case TMF.ISubType 
--										when 168 then 'Received'
--										else 'Sended'
--									end  			  
--								else
--									case TMF.AuctionState
--										WHEN 0 THEN 'Programmata'
--										WHEN 1 THEN 'InCorso'
--										WHEN 2 THEN 'Chiusa'
--										WHEN 3 THEN 'Annullata'
--									end
--							end 	
							
--					end 
					
					
--				end	
--	 end as StatoCollegati
--	, '' as OPEN_DOC_NAME
--	, cast(TMF.isubtype as varchar) Folder 
--FROM 
    
--	--TAB_UTENTI_MESSAGGI TUM
--	TAB_MESSAGGI_FIELDS TMF
--	, --AZIENDE A,PROFILIUTENTE P,
--	(
	
--        select 
--			distinct linkeddoc,P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato
--		from 
--			ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P 
--		where 
--			D.tipodoc='offerta_partecipanti' and DO.idheader=D.id and D.jumpcheck='DocumentoGenerico' and D.statofunzionale='pubblicato'
--			and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
--			and P.pfuidazi=idazi
--                --and fascicolo='PROVV01210'
                

--	) PO
	
--WHERE 
	  
--	  --TMF.protocolbg=PO.fascicolo	
--	  --AND TMF.Itype = 55
--	  --AND ( TMF.isubtype = 168 or (TMF.isubtype = 186 and TMF.idaziendaati<>'' ) or (TMF.isubtype = 22 and TMF.idaziendaati<>'' ) )
--	  --AND ( TMF.isubtype = 168 or TMF.isubtype = 186 or TMF.isubtype = 22 )
--	  --AND TMF.IdMsg = TUM.umIdMsg
--          --AND TUM.umInput = 0
--	  --AND TUM.umstato=0
--	  --AND PO.idpfu = P.idpfu
--	  --AND P.pfuidazi=A.idazi
--	  --AND PO.IdPfuInvitato  = TUM.umidpfu
--	  --AND TUM.umidpfu>0 
--          PO.linkeddoc=TMF.idmsg

--UNION ALL

----BANDI INDIRETTI A CUI PARTECIPO
--SELECT 
--     TMF.IdMsg
--     , PO.IdPfu AS IdPfu
--     , TMF.IType
--     , TMF.ISubType  as msgisubtype  
--      ,TMF.name  AS Name	
--      ,TMF.[Read] AS bRead       
--      ,TMF.[Object] AS Oggetto        
--      ,TMF.ProtocolloBando AS ProtocolloBando     
--      ,TMF.ProtocolBG AS Fascicolo        
--      ,TMF.ProtocolloOfferta AS ProtocolloOfferta 	      
--      ,ltrim(rtrim(TMF.Stato)) AS StatoGD
--      ,TMF.AdvancedState AS AdvancedState           
--      ,TMF.ReceivedDataMsg  AS ReceivedDataMsg   
--      ,TMF.IdMittente AS IdMittente 	        
--      ,TMF.ECONOMICA_ENCRYPT as Cifratura
--      ,'' as azipartitaiva
--      ,'' as idAziPartecipante --a.idazi as idAziPartecipante
--	  , 'MESSAGE_' + CAST( TMF.IType AS VARCHAR ) + '_' + cast( TMF.ISubType as varchar ) as DocType ,
	 
--	  case  TMF.Stato 
--		WHEN 1 THEN 'Saved'
--		WHEN 4 THEN 'Invalidate'
--		WHEN 2 then
			
--			CASE TMF.AdvancedState
--				WHEN 0 THEN
					
--					case TMF.ISubType 
--						when '168' then 'Received'
--						else 'Sended'
--					end   
				
--				ELSE
					
--					case TMF.AdvancedState
--						WHEN '' THEN
--							case TMF.ISubType 
--								when '168' then 'Received'
--								else 'Sended'
--							end  
						
--						WHEN 1 THEN 'Confirmed'
--						WHEN 2 THEN 'Rejected'
--						WHEN 3 THEN 'Revoke'
--						WHEN 4 THEN 'InApprove'
--						WHEN 5 THEN 'NotApprove'
--						WHEN 6 THEN 'Correct'
--						WHEN 7 THEN 'Revoke2'
--						WHEN 0 THEN
							
--							case TMF.AuctionState
--								WHEN 0 THEN
--									case TMF.ISubType 
--										when 168 then 'Received'
--										else 'Sended'
--									end  			  
--								else
--									case TMF.AuctionState
--										WHEN 0 THEN 'Programmata'
--										WHEN 1 THEN 'InCorso'
--										WHEN 2 THEN 'Chiusa'
--										WHEN 3 THEN 'Annullata'
--									end
--							end 	
							
--					end 
					
					
--				end	
--	 end as StatoCollegati
--	, '' as OPEN_DOC_NAME
--	, cast(TMF.isubtype as varchar) Folder 
--FROM 
    
--	TAB_UTENTI_MESSAGGI TUM
--	,TAB_MESSAGGI_FIELDS TMF
--	, AZIENDE A,PROFILIUTENTE P,
--	(
	
     
--        --prendo min  degli invitati e faccio group by P.idpfu,fascicolo per evitare di avere bandi duplicati negli indiretti
--       --quando un fornitore partecipa indirettamente + volte con diversi altri fornitori
--       select 
--		P.idpfu,fascicolo,min(D.IdPfu) as IdPfuInvitato
--                --distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato
--       from 
--		ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P  
--       where 
--		D.tipodoc='OFFERTA_PARTECIPANTI' and DO.idheader=D.id 
--		and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
--		and P.pfuidazi=idazi
--                --and fascicolo='PROVV01210'
--       group by P.idpfu,fascicolo
                

--	) PO
	
--WHERE 
	  
--	  TMF.protocolbg=PO.fascicolo	
--	  AND TMF.Itype = 55
--	  AND TMF.isubtype = 168
--	  AND TMF.IdMsg = TUM.umIdMsg
--          AND TUM.umInput = 0
--	  AND TUM.umstato=0
--	  AND PO.idpfu = P.idpfu
--	  AND P.pfuidazi=A.idazi
--	  AND PO.IdPfuInvitato  = TUM.umidpfu
          
--	  AND TUM.umidpfu>0 
          


--UNION ALL

--QUESITI INDIRETTI
select  
	id AS IdMsg
	, PO.idpfu
    , '' AS msgIType
    , '-1' AS msgISubType
    , aziragionesociale as Name
	, 0 as bread
	, a.domanda as Oggetto	
    , ProtocolloBando
	, a.Fascicolo       
    , Protocol as ProtocolloOfferta
    , '2' as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),a.DataCreazione , 20 ) as ReceivedDataMsg
    , ''  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, 'DETAIL_CHIARIMENTI' as DocType
    , 'Sended' as  StatoCollegati
    --, 'NUOVIQUESITI' as tipo 
    , 'CHIARIMENTI_COLLEGATI' as OPEN_DOC_NAME
    , '' as Folder 

         from 
        	CHIARIMENTI_PORTALE_BANDO a ,
        	(
				select 
					 distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato
				from 
					ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P 
				where 
					D.tipodoc='offerta_partecipanti' and DO.idheader=D.id 
					and DO.TipoRiferimento in ('RTI','ESECUTRICI') --and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
					and P.pfuidazi=idazi
					and D.jumpcheck<>'DocumentoGenerico'
						   --and fascicolo='PROVV01210'
        	) PO
        	inner join ProfiliUtenteAttrib pa on pa.idpfu = po.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
        where 
        	PO.idpfuinvitato=a.utentedomanda
        	and a.Fascicolo=PO.fascicolo	
			and document<>''	
                

UNION ALL
  --per prendere i propri chiarimenti
  select  
	id AS IdMsg
	, b.idpfu
    , '' AS msgIType
    , '-1'  AS msgISubType
    , aziragionesociale as Name
	, 0 as bread
	, a.domanda as Oggetto	
    , ProtocolloBando
	, a.Fascicolo       
    , Protocol as ProtocolloOfferta
    , '2' as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),a.DataCreazione , 20 ) as ReceivedDataMsg
    , ''  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, 'DETAIL_CHIARIMENTI' as DocType
    , 'Sended' as  StatoCollegati
    --, 'NUOVIQUESITI' as tipo 
    , 'CHIARIMENTI_COLLEGATI' as OPEN_DOC_NAME
    , '' as Folder 

 from 
	CHIARIMENTI_PORTALE_BANDO a ,
	profiliutente b 
	inner join ProfiliUtenteAttrib pa on pa.idpfu = b.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
 where 
	b.idpfu=utentedomanda
	and document<>''

UNION ALL

-----------------------------------------------------
--aggiunge le comunicazioni alla lista dei documenti collegati
-----------------------------------------------------

  select  
         id AS IdMsg
        , PO.idpfu
        , '' AS msgIType
        , case  
		when TipoDoc in ('PDA_COMUNICAZIONE_OFFERTA_RISP','OFFERTA') then '186'
		else 'PDA_COMUNICAZIONE_GARA' 
	        end AS msgISubType
        , Titolo as Name
        , 0 as bread
        , cast(CTL_DOC.body as nvarchar(4000)) as Oggetto	
        , ProtocolloRiferimento AS ProtocolloBando   
        , CTL_DOC.Fascicolo       
        , Protocollo as ProtocolloOfferta
        ,  case statodoc 
        	when 'saved' then '1' 
        	else '2' 
          end  as StatoGD
        , '' as AdvancedState
        , convert(varchar(20),CTL_DOC.DataInvio , 20 ) as ReceivedDataMsg
        , ctl_doc.idpfu  as IdMittente
        , '0' as Cifratura
        , '' as azipartitaiva
        , '' as idAziPartecipante
        , TipoDoc as DocType
	, case 
			when TipoDoc in ('PDA_COMUNICAZIONE_OFFERTA_RISP','PDA_COMUNICAZIONE_RISP','OFFERTA') then
				case StatoDoc 
					when 'Invalidate' then 'Annullata'
					else StatoDoc
				end
			else 
				case StatoDoc 
					when 'Sended' then 'Received'
					when 'Invalidate' then 'Annullata'
					else 'Received'
				end 
				 
	   end as StatoCollegati		
        , TipoDoc as OPEN_DOC_NAME
	, case  
		when TipoDoc in ('PDA_COMUNICAZIONE_OFFERTA_RISP','OFFERTA') then '186'
		else 'PDA_COMUNICAZIONE_GARA' 
	        end as Folder

 from CTL_DOC 
  inner join (

                --ho aggiunto and PO.linkeddoc= CTL_DOC.linkeddoc per essere sicuro di prendere le comunicazioni su quel bando
                --altrimenti in caso di doppio giro fa il prodotto cartesiano con altri che non c'entrano nulla
        
			select 
				distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato,D.linkeddoc
			from 
				ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P --, document_offerta_partecipanti DO1
			where 
				D.tipodoc='offerta_partecipanti' and DO.idheader=D.id 
				and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
				and P.pfuidazi=DO.idazi --and D.fascicolo='PROVV01234'
				and D.jumpcheck<>'DocumentoGenerico'

	      ) PO on   PO.fascicolo=CTL_DOC.fascicolo   and PO.linkeddoc= CTL_DOC.linkeddoc --( Destinatario_azi=idazi or azienda = idazi)

		  inner join ProfiliUtenteAttrib pa on pa.idpfu = po.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'

                
where 
	(
	  ( TipoDoc in ( 'PDA_COMUNICAZIONE_GARA', 'PDA_COMUNICAZIONE_OFFERTA' ) and StatoDoc='Sended' )
	  or 
	  ( TipoDoc in (  'PDA_COMUNICAZIONE_RISP' ,  'PDA_COMUNICAZIONE_OFFERTA_RISP' , 'OFFERTA' ) )
	)
	 
	and deleted = 0



-------------------------------------------------------
----COMUNICAZIONI ESITO GARA DELLA PDA FLUSSO UNICO
-------------------------------------------------------
--UNION ALL

--  select  
--         idrow AS IdMsg
--        , PO.idpfu
--        , '' AS msgIType
--        , 'PDA_COMUNICAZIONE_GARA'  AS msgISubType
--        , EF.Titolo as Name
--        , 0 as bread
--        , cast(E.Oggetto as nvarchar(4000)) as Oggetto	

--        , TM.ProtocolloBando
--        , TM.ProtocolBG as Fascicolo       
--        , EF.Protocollo as ProtocolloOfferta
--        , '2' as StatoGD
--        , '' as AdvancedState
--        , convert(varchar(20),EF.DataInvio , 20 ) as ReceivedDataMsg
--        , E.idpfu  as IdMittente
--        , '0' as Cifratura
--        , '' as azipartitaiva
--        , '' as idAziPartecipante
--        , 'COM_ESITO_GARA_FORNITORE' as DocType
--        --, EF.Stato as  StatoCollegati
--        , case EF.Stato 
--        	when 'Sended' then 'Received'
--        	when 'Invalidate' then 'Annullata'
--        	else 'Received'
--           end as  StatoCollegati
--        , 'COM_ESITO_GARA_FORNITORE' as OPEN_DOC_NAME
--        , 'PDA_COMUNICAZIONE_GARA' as Folder
 
--from tab_messaggi_fields TM 
--	inner join Document_EsitoGara E on E.ID_MSG_BANDO=TM.idmsg
--	inner join Document_EsitoGara_Fornitori EF on E.id=EF.idheader
--	inner join --ProfiliUtente on  EF.Fornitore=pfuidazi 
--                (
--			select 
--				distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato,D.azienda as idazi
--			from 
--				ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P --, document_offerta_partecipanti DO1
--			where 
--				D.tipodoc='offerta_partecipanti' and DO.idheader=D.id 
--				and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
--				and P.pfuidazi=DO.idazi --and fascicolo='PROVV01207'
--                                --and DO1.TipoRiferimento = 'RTI' and isnull(DO1.Ruolo_impresa,'') = 'Mandataria'
--                                --and DO1.idheader=D.id 

--	      ) PO on PO.fascicolo=TM.ProtocolBG and  EF.Fornitore=PO.idazi 
--where 
--  EF.Stato='Sended'



-------------------------------------------------------
----COMUNICAZIONI AGGIUDICATARIA GARA DELLA PDA FLUSSO UNICO
-------------------------------------------------------
--UNION ALL

--  select  
--         id AS IdMsg
--        , PO.idpfu
--        , '' AS msgIType
--        , 'PDA_COMUNICAZIONE_GARA'  AS msgISubType
--        , A.Titolo as Name
--        , 0 as bread
--        , cast(A.Oggetto as nvarchar(4000)) as Oggetto	
--        , TM.ProtocolloBando
--        , TM.ProtocolBG as Fascicolo       
--        , A.Protocollo as ProtocolloOfferta
--        , '2' as StatoGD
--        , '' as AdvancedState
--        , convert(varchar(20),A.DataInvio , 20 ) as ReceivedDataMsg
--        , A.idpfu  as IdMittente
--        , '0' as Cifratura
--        , '' as azipartitaiva
--        , '' as idAziPartecipante
--        , 'PDA_COMUNICAZIONE_GARA' as DocType
--        , case A.Stato 
--        	when 'Sended' then 'Received'
--        	when 'Invalidate' then 'Annullata'
--        	else 'Received'
--           end as  StatoCollegati
--        , 'COM_AGGIUDICATARIA' as OPEN_DOC_NAME
--        , 'PDA_COMUNICAZIONE_GARA' as Folder
 
--from tab_messaggi_fields TM 
--	inner join Document_Com_Aggiudicataria A on A.ID_MSG_BANDO=TM.idmsg
--	inner join --ProfiliUtente on  A.idAggiudicatrice=pfuidazi 
--                (
--			select 
--				distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato,D.azienda as idazi
--			from 
--				ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P --, document_offerta_partecipanti DO1
--			where 
--				D.tipodoc='offerta_partecipanti' and DO.idheader=D.id 
--				and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
--				and P.pfuidazi=DO.idazi --and fascicolo='PROVV01207'
--                                --and DO1.TipoRiferimento = 'RTI' and isnull(DO1.Ruolo_impresa,'') = 'Mandataria'
--                                --and DO1.idheader=D.id 

--	      ) PO on A.idAggiudicatrice=PO.idazi and PO.fascicolo=TM.ProtocolBG 
--where 
--  A.Stato='Sended'




-------------------------------------------------------
----COMUNICAZIONI STIPULA CONTRATTO DELLA PDA FLUSSO UNICO
-------------------------------------------------------
--UNION ALL

--  select  
--         idrow AS IdMsg
--        , PO.idpfu
--        , '' AS msgIType
--        , 'PDA_COMUNICAZIONE_GARA'  AS msgISubType
--        , EF.TitoloStipula as Name
--        , 0 as bread
--        , cast(E.Oggetto as nvarchar(4000)) as Oggetto	
--        , TM.ProtocolloBando
--        , TM.ProtocolBG as Fascicolo       
--        , EF.ProtocolloStipula as ProtocolloOfferta
--        , '2' as StatoGD
--        , '' as AdvancedState
--        , convert(varchar(20),EF.DataInvioStipula , 20 ) as ReceivedDataMsg
--        , E.idpfu  as IdMittente

--        , '0' as Cifratura
--        , '' as azipartitaiva
--        , '' as idAziPartecipante

--        , 'COM_STIPULA_CONTRATTO' as DocType
--        	, case EF.StatoStipula 
--        	when 'Sended' then 'Received'
--        	when 'Invalidate' then 'Annullata'
--        	else 'Received'
--           end as  StatoCollegati
--        , 'COM_STIPULA_CONTRATTO' as OPEN_DOC_NAME
--        , 'PDA_COMUNICAZIONE_GARA' as Folder
 
--from tab_messaggi_fields TM 
--	inner join Document_EsitoGara E on E.ID_MSG_BANDO=TM.idmsg
--	inner join Document_EsitoGara_Fornitori EF on E.id=EF.idheader
--	inner join --ProfiliUtente on  EF.Fornitore=pfuidazi 
--                (
--			select 
--				distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato,D.azienda as idazi
--			from 
--				ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P --, document_offerta_partecipanti DO1
--			where 
--				D.tipodoc='offerta_partecipanti' and DO.idheader=D.id 
--				and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
--				and P.pfuidazi=DO.idazi
--                                --and DO1.TipoRiferimento = 'RTI' and isnull(DO1.Ruolo_impresa,'') = 'Mandataria'
--                                --and DO1.idheader=D.id 

--	      ) PO on EF.Fornitore=PO.idazi and PO.fascicolo=TM.ProtocolBG 
--where 
--  EF.StatoStipula='Sended'


-----------------------------------------------------
--NUOVI BANDI A CUI PARTECIPO INDIRETTAMENTE
-----------------------------------------------------
UNION ALL

	select 
		distinct 
		d.id as IdMsg 
		,PO.IdPfu
		,1000 as msgIType
		,'168' as msgISubType
		,Titolo as Name
		,case when isnull( r.id , 0 ) = 0 then 1 else 0 end as  bRead
		, cast(d.body as nvarchar(4000)) as Oggetto	
		,ProtocolloBando
		,d.Fascicolo
		,Protocollo as ProtocolloOfferta
		, '2' as StatoGD
        , '' as AdvancedState
		, convert(varchar(20),DataInvio , 20 ) as ReceivedDataMsg
		--, p.idpfu  as IdMittente
		,''  as IdMittente
		, '0' as Cifratura
        , '' as azipartitaiva
        , '' as idAziPartecipante		
		, tipodoc as DocType
		, case StatoDoc 
        	when 'Sended' then 'Received'
        	when 'Invalidate' then 'Annullata'
        	else 'Received'
           end as  StatoCollegati
        , tipodoc as OPEN_DOC_NAME
        , '168' as Folder

	from ctl_doc d
		inner join document_bando b on d.id = b.idheader
		inner join CTL_DOC_Destinatari ds on  ds.idHeader = d.id
		inner join profiliutente p on p.pfuidazi = ds.IdAzi
		inner join aziende az on az.idazi=d.Azienda   ---per recuperare l'enteAppaltante
		left outer join (
			select max( id ) as id ,LinkedDoc , azienda from CTL_DOC where TipoDoc = 'OFFERTA' and deleted = 0 group by LinkedDoc , azienda
			) as lo on lo.LinkedDoc = d.id and ds.idAzi = lo.azienda
		left outer join (select id , statofunzionale from CTL_DOC where TipoDoc = 'OFFERTA') as ld on lo.id = ld.id
		left outer join DOCUMENT_RISULTATODIGARA DR on DR.ID_MSG_BANDO=-d.id and DR.TipoDoc_src=D.TipoDoc
		left outer join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='PROROGA_GARA') V on V.LinkedDoc=d.id
		left outer join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='RETTIFICA_GARA') Z on Z.LinkedDoc=d.id
																				-- il tipo doc è stato troncato a 18 perchè lato fornitore il documento che apre è il
																				-- BANDO_SEMPLIFICATO_INVITO mentre il documento è BANDO_SEMPLIFICATO
		

		inner join 
                (
				select 
					distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato,D.azienda as idazi
				from 
					ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P 
				where 
					D.tipodoc='offerta_partecipanti' and DO.idheader=D.id and jumpcheck<>'DocumentoGenerico'
					and D.statofunzionale='Pubblicato'
					and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
					and P.pfuidazi=DO.idazi
					--and fascicolo='FE000441'
			) PO on p.pfuidazi=PO.idazi and PO.fascicolo=D.Fascicolo
					
		
		inner join ProfiliUtenteAttrib pa on pa.idpfu = po.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'

		left outer join CTL_DOC_READ r with(nolock) on  r.idPfu = po.IdPfu and left( r.DOC_NAME , 18 ) = left( d.tipoDoc ,18 ) and r.id_Doc = d.id


	where tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and 
			--statofunzionale in ('Pubblicato') and 
			d.statofunzionale not in ('InLavorazione' , 'InApprove' ) and 
			deleted = 0
			

UNION ALL

--NUOVE OFFERTE A CUI PARTECIPO INDIRETTAMENTE
SELECT 
     O.Id
     , PO.IdPfu AS IdPfu
     , '1000' as IType
     , '186'  as msgisubtype  
     , O.Titolo  AS Name	
     , case when isnull( r.id , 0 ) = 0 then 1 else 0 end as  bRead      
     , cast(O.body as nvarchar(4000)) as Oggetto	       
     , O.ProtocolloRiferimento as ProtocolloBando     
     , O.Fascicolo        
     , O.Protocollo AS ProtocolloOfferta 	      
     , '2' as StatoGD
     , '' as AdvancedState
	 , convert(varchar(20),DataInvio , 20 ) as ReceivedDataMsg
     , O.idpfu AS IdMittente 	        
     , '0' as Cifratura
     , '' as azipartitaiva
     , '' as idAziPartecipante		
	 , O.tipodoc as DocType
	 , case StatoDoc 
        	when 'Sended' then 'Sended'
        	when 'Invalidate' then 'Annullata'
        	else 'Received'
        end as  StatoCollegati
     , O.tipodoc as OPEN_DOC_NAME
     , '186' as Folder
FROM 
	CTL_DOC O
		inner join 
			(
			
				select 
					distinct linkeddoc,P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato
				from 
					ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P 
				where 
					D.tipodoc='offerta_partecipanti' and DO.idheader=D.id and D.jumpcheck<>'DocumentoGenerico' and D.statofunzionale='pubblicato'
					and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
					and P.pfuidazi=idazi
		                

			) PO on PO.linkeddoc=O.id
			inner join ProfiliUtenteAttrib pa on pa.idpfu = po.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
			left outer join CTL_DOC_READ r with(nolock) on  r.idPfu = PO.IdPfu and left( r.DOC_NAME , 18 ) = left( O.tipoDoc ,18 ) and r.id_Doc = O.id
	

	  




GO
