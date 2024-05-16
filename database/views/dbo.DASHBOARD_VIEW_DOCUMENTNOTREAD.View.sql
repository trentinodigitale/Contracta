USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTNOTREAD]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_DOCUMENTNOTREAD]  AS

SELECT IdMsg
     , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
     , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS Name
     , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
       END AS ProtocolloBando
     , CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 11)
       END AS ProtocolloOfferta
     , CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 19)
       END AS ReceivedDataMsg
     , CAST(a.mlngDesc_I AS VARCHAR(200)) + '/' + CAST(b.mlngDesc_I AS VARCHAR(200)) AS Path
 FROM TAB_MESSAGGI WITH (INDEX(IX_TAB_MESSAGGI_3))
    , TAB_UTENTI_MESSAGGI WITH (INDEX(IX_TAB_UTENTI_MESSAGGI))
    , MPCommands
    , MPGroups
    , Multilinguismo a
    , Multilinguismo b
WHERE IdMsg = umIdMsg
  AND msgItype = 55
  AND umInput = 0
  AND umStato = 0
  AND SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 1) = 1
  AND dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 10)) <> CAST(umIdPfu AS VARCHAR)
  AND umIdPfu <> -10
  AND msgItype = mpcItype
  AND msgISubType = mpcISubType
  AND mpcIdGroup = mpgIdGroup
  AND mpcName = b.IdMultilng
  AND mpgGroupName = a.IdMultilng
  AND mpcDeleted = 0
  AND mpgIdGroup <> 5
  AND msgISubType NOT IN (23, 29, 39, 55,95,127,151)

UNION ALL  
SELECT IdMsg
     , umIdPfu
     , msgIType
     , msgISubType
     , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS Name
     , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
       END AS ProtocolloBando
     , CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 11)
       END AS ProtocolloOfferta
     , CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 19)
       END AS ReceivedDataMsg
     , CAST(a.mlngDesc_I AS VARCHAR(200)) AS Path
 FROM TAB_MESSAGGI WITH (INDEX(IX_TAB_MESSAGGI_3))
    , TAB_UTENTI_MESSAGGI  WITH (INDEX(IX_TAB_UTENTI_MESSAGGI))        
    , MPCommands
    , MPGroups
    , Multilinguismo a
WHERE IdMsg = umIdMsg
  AND msgItype = 55
  AND umInput = 0
  AND umStato = 0
  AND SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 1) = 1
  AND dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 10)) <> CAST(umIdPfu AS VARCHAR)
  AND umIdPfu <> -10
  AND msgItype = mpcItype
  AND msgISubType = mpcISubType
  AND mpcIdGroup = mpgIdGroup
  AND mpgGroupName = a.IdMultilng
  AND mpcDeleted = 1
  AND mpgIdGroup <> 5
  AND msgISubType NOT IN (23, 29, 39, 55,95,127,151)




GO
