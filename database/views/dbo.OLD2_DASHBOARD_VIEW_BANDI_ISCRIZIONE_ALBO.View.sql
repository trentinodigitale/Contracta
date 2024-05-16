USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_BANDI_ISCRIZIONE_ALBO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_BANDI_ISCRIZIONE_ALBO]  AS
SELECT IdMsg
     , umIdPfu AS IdPfu
     , iType as msgIType
     , iSubType as msgISubType
     ,Name
     ,ProtocolloBando
     ,ReceivedDataMsg
     ,ProtocolBG as Fascicolo
     ,ReceivedIscrizioni
--     , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
--       END AS Name
--     , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
--       END AS ProtocolloBando
--	 , CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 20)) 
--       END AS StatoGD     
--	, CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 20)) 
--       END AS ProtocolloOfferta
--     , CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
--       END AS ReceivedDataMsg
--     , CASE CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000)))
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) 
--       END AS expirydate
--      , CASE CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000)))
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) 
--       END AS Fascicolo
--	, CASE CHARINDEX ('<AFLinkFieldReceivedIscrizioni>', CAST(MSGTEXT AS VARCHAR(8000)))
--            WHEN 0 THEN ''
--            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedIscrizioni>', CAST(MSGTEXT AS VARCHAR(8000))) + 31, 20)) 
--       END AS ReceivedIscrizioni
--  FROM 
--tab_utenti_messaggi, 
--tab_messaggi
--WHERE 
--IdMsg = umIdMsg
--  AND msgItype = 55
--  and msgisubtype= 10
--  AND umInput = 0
--  AND umstato=0
  
   FROM 
tab_utenti_messaggi
inner join TAB_MESSAGGI_FIELDS as tb on umIdMsg=IdMsg
WHERE 
  Itype = 55
  and isubtype= 10
  AND umInput = 0
  AND umstato=0


GO
