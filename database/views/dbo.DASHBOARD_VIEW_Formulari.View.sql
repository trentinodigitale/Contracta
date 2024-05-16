USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Formulari]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_Formulari]  AS
SELECT IdMsg
     , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
     , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS Nome
     , CASE CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 100)) 
       END AS Oggetto
     , CASE CHARINDEX ('<AFLinkFieldTipoProcedura>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldTipoProcedura>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 25))
       END AS TipoProcedura
     , CASE CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) 
       END AS ExpiryDate
     , 1 AS OpenDettaglio
  FROM FolderDocuments
     , FolderTypes
     , Document
     , TAB_UTENTI_MESSAGGI
     , TAB_MESSAGGI
 WHERE ftIdPf = fdIdPf
   AND fdIdPfu = umIdPfu  
   AND IdMsg = umIdMsg  
   AND IdMsg = fdIdMsg
   AND msgIType = dcmIType  
   AND msgISubType = dcmISubType  
   AND msgIType = 55  
   AND msgISubType = 181
   AND ftIdDcm = IdDcm  
   AND umIdPfu = -10 
   AND ftDeleted = 0  
   AND dcmDeleted = 0  
   AND umIdPfu = -10
   and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 40))  <> '6'

GO
