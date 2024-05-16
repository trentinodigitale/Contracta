USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COMUNICAZIONIALBO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_COMUNICAZIONIALBO]  AS
SELECT IdMsg
     , umIdPfu AS IdPfu
     ,IType as  msgIType
     , ISubType as ISubTypemsg 
     ,Name
     ,Object as Oggetto
     ,ProtocolloBando
     ,ProtocolloOfferta
     ,RagSoc as aziRagioneSociale
     ,stato as StatoGD
     ,[Read] as bRead
     ,ADVANCEDSTATE
     ,ReceivedDataMsg
 --    , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
 --      END AS Name
 --    ,CASE CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000))) 
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 400)) 
 --      END AS Oggetto
 --    , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
 --      END AS ProtocolloBando
 --    , CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 20)) 
 --      END AS ProtocolloOfferta
 --    , CASE CHARINDEX ('<AFLinkFieldRagSoc>', CAST(MSGTEXT AS VARCHAR(8000)))
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRagSoc>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 20)) 
 --      END AS aziRagioneSociale
 --    , CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 20)) 
 --      END AS StatoGD
	--, CASE CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) 
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRead>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
 --      END AS bRead 
 --    , CASE CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000)))
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 20)) 
 --      END AS ADVANCEDSTATE
 --    , CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
 --           WHEN 0 THEN ''
 --           ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
 --      END AS ReceivedDataMsg
	  ,f.vatvalore_ft as codicefiscale
      ,azipartitaiva
      ,a.idazi as idAziPartecipante
 FROM TAB_MESSAGGI_FIELDS as tb
    , TAB_UTENTI_MESSAGGI
	, aziende a	
	, profiliutente p
    left outer join dm_attributi f on  p.pfuidazi=f.lnk and f.dztnome = 'codicefiscale' and f.idapp=1
WHERE IdMsg = umIdMsg
  AND Itype = 55
  and isubtype =91
  AND umInput = 0
  AND umstato=0
  AND umIdPfu <> -10
  and tb.IdMittente=p.idpfu 
  and p.pfuidazi=a.idazi


GO
