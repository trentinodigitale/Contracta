USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_QUESITI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_QUESITI]  AS
SELECT IdMsg
     , umIdPfu                  AS IdPfu
     , IType as msgIType
     , ISubType as msgISubType
     ,Name
     ,ProtocolloBando
     ,ProtocolloOfferta
     ,ReceivedDataMsg
     ,Object_Cover1 as Oggetto
     ,[Read] as bRead
     ,RagSoc as aziRagioneSociale
     --, CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
     --  END AS Name
     --, CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
     --  END AS ProtocolloBando
     --, CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 20)) 
     --  END AS ProtocolloOfferta
     --, CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
     --  END AS ReceivedDataMsg
     --, CASE CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN '_'
     --       ELSE ISNULL(NULLIF(REPLACE(dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)), CHAR(9), ''), ''), '_')
     --  END AS Oggetto
     --, CASE CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) 
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
     --  END AS bRead
     --, CASE CHARINDEX ('<AFLinkFieldRagSoc>', CAST(MSGTEXT AS VARCHAR(8000))) 
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRagSoc>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 400)) 
     --  END AS aziRagioneSociale
     , aziPartitaIva
     , IdAzi AS idAziPartecipante
     , vatValore_FT AS CodiceFiscale
  FROM TAB_MESSAGGI_FIELDS as tb
     , TAB_UTENTI_MESSAGGI
     , ProfiliUtente
     , Aziende
     , DM_Attributi
 WHERE umIdMsg = IdMsg  
   AND IType = 55
   AND ISubType IN (1, 45, 51, 123)
   AND tb.IdMittente = IdPfu
   AND pfuIdAzi = lnk AND dztNome = 'CodiceFiscale' 
   AND pfuIdAzi = IdAzi
   AND IdApp = 1
   AND umIdPfu <> -10

GO
