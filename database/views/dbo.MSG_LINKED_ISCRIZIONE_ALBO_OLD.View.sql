USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_LINKED_ISCRIZIONE_ALBO_OLD]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MSG_LINKED_ISCRIZIONE_ALBO_OLD]  AS
SELECT IdMsg
     , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
     , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS Name
	, CASE CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS bRead
     ,CASE CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 400)) 
       END AS Oggetto
     , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
       END AS ProtocolloBando
		, CASE CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 20)) 
       END AS Fascicolo
     , CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 20)) 
       END AS ProtocolloOfferta
     , CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 20)) 
       END AS StatoGD
     , CASE CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 20)) 
       END AS AdvancedState
     , CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
       END AS ReceivedDataMsg
     , CASE CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 20)) 
       END AS IdMittente
	 , CASE CHARINDEX ('<AFLinkFieldECONOMICA_ENCRYPT>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN '0'
			ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldECONOMICA_ENCRYPT>', CAST(MSGTEXT AS VARCHAR(8000))) + 32, 25)) 
       END AS Cifratura
	  ,azipartitaiva
      ,a.idazi as idAziPartecipante
     , 'MESSAGE_' + CAST( msgIType AS VARCHAR ) + '_' + cast( msgISubType as varchar ) as DocType ,
	 case  dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 20)) 
		WHEN 1 THEN 'Saved'
		WHEN 4 THEN 'Invalidate'
		WHEN 2 then
			CASE CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000)))
				WHEN 0 THEN
					
					case a.idazi
						when 35152001 then 'Received'
						else 'Sended'
					end  
				
				ELSE
					
					case dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 20)) 
						WHEN '' THEN
							case a.idazi
								when 35152001 then 'Received'
								else 'Sended'
							end  
						
						WHEN 1 THEN 'Confirmed'
						WHEN 2 THEN 'Rejected'
						WHEN 3 THEN 'Revoke'
						WHEN 4 THEN 'InApprove'
						WHEN 5 THEN 'NotApprove'
						WHEN 6 THEN 'Correct'
						WHEN 0 THEN
							
							case CHARINDEX ('<AFLinkFieldAuctionState>', CAST(MSGTEXT AS VARCHAR(8000)))
								WHEN 0 THEN
									case a.idazi
										when 35152001 then 'Received'
										else 'Sended'
									end					  
								else
									case dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAuctionState>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 20)) 
										WHEN 0 THEN 'Programmata'
										WHEN 1 THEN 'InCorso'
										WHEN 2 THEN 'Chiusa'
										WHEN 3 THEN 'Annullata'
									end
							end 	
							
					end 
					
					
				end	
	 end as StatoCollegati
	, '' as OPEN_DOC_NAME

 FROM TAB_MESSAGGI
    , TAB_UTENTI_MESSAGGI
	, aziende a	
	, profiliutente p
	WHERE 
  IdMsg = umIdMsg
  AND msgItype = 55
  --and msgisubtype IN (11,12,15,17,31,40,90,93,177)
  AND umInput = 0
  AND umstato=0
  AND umIdPfu <> -10
  and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 20)) =p.idpfu 
  and p.pfuidazi=a.idazi

--aggiunge i nuovi quesiti
  union all
  select  
	id AS IdMsg
	, b.idpfu
    , '' AS msgIType
	, ''  AS msgISubType
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

 from CHIARIMENTI_PORTALE_BANDO a ,
 profiliutente b where idpfu=utentedomanda

GO
