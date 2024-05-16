USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONFERME_ISTANZA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_CONFERME_ISTANZA]  AS
SELECT IdMsg
     , umIdPfu AS IdPfu
     , IType as msgIType
     , ISubType as msgISubType
     ,Name
     ,aziRagioneSociale
     ,ProtocolloBando
     ,sysHabilitStartDate
     ,stato as StatoGD
     --, CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
     --  END AS Name
     --, CASE CHARINDEX ('<AFLinkFieldRAGSOCDEST>', CAST(MSGTEXT AS VARCHAR(8000))) 
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRAGSOCDEST>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 400)) 
     --  END AS aziRagioneSociale
     --, CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
     --  END AS ProtocolloBando
     --, CASE CHARINDEX ('<AFLinkFieldsysHabilitStartDate>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldsysHabilitStartDate>', CAST(MSGTEXT AS VARCHAR(8000))) + 32, 20)) 
     --  END AS sysHabilitStartDate
     --, CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
     --       WHEN 0 THEN ''
     --       ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 20)) 
     --  END AS StatoGD
     , IdAzi AS IdAziPartecipante
     , aziPartitaIVA  
     , vatValore_FT AS CodiceFiscale
  FROM TAB_MESSAGGI_FIELDS as tb
     , TAB_UTENTI_MESSAGGI
     , ProfiliUtente
     , Aziende 
     LEFT OUTER JOIN DM_Attributi ON IdAzi = Lnk
 WHERE IdMsg = umIdMsg
   AND Itype = 55
   AND isubtype = 14
   AND umInput = 0
   AND umstato = 0
   AND IdApp = 1
   AND dztNome = 'CodiceFiscale'
   AND IdAzi = pfuIdAzi
   AND IdPfu = tb.IdDestinatario--dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdDestinatario>', CAST(MSGTEXT AS VARCHAR(8000))) + 27, 20))


GO
