USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_IstanzeEvase]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_IstanzeEvase]
AS 
SELECT v.* 
     , f.vatvalore_ft AS codicefiscale
     , azipartitaiva
     , a.idazi        AS idAziPartecipante
  FROM 
(
SELECT IdMsg
     , umIdPfu as IdPfu
     , IType as msgIType
     , ISubType as msgISubType
     ,Name
     ,Object as Oggetto
     ,ProtocolloBando
     ,ProtocolloOfferta
     ,RagSoc as aziRagioneSociale
     ,Stato
     ,rtrim(ltrim(ADVANCEDSTATE)) as ADVANCEDSTATE
     ,ReceivedDataMsg
     ,IdMittente
     --, CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
     --  END AS Name
     --,CASE CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000))) 
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 400)) 
     --  END AS Oggetto
     --, CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
     --  END AS ProtocolloBando
     --, CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 20)) 
     --  END AS ProtocolloOfferta
     --, CASE CHARINDEX ('<AFLinkFieldRagSoc>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRagSoc>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 20)) 
     --  END AS aziRagioneSociale
     --, CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 20)) 
     --  END AS Stato
     --, CASE CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 20)) 
     --  END AS ADVANCEDSTATE
     --, CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
     --  END AS ReceivedDataMsg
     --, CASE CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 20))
     --  END AS IdMittente
 FROM TAB_MESSAGGI_FIELDS as tb 
    , TAB_UTENTI_MESSAGGI
WHERE IdMsg = umIdMsg
  AND Itype = 55
  and isubtype IN (13,178)
 -- AND msgPriorita <> -1
 -- AND msgElabWithSuccess = -1
  AND umInput = 0
  AND umstato=0
  AND umIdPfu <> -10
) V
, profiliutente p
, aziende a	
    LEFT OUTER JOIN dm_attributi f on  a.idazi=f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1

WHERE CAST(V.IdMittente AS INT) = p.IdPfu
  AND V.AdvancedState <> ''
  AND V.AdvancedState <> '0'
  AND p.pfuidazi = a.idazi



GO
