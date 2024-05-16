USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Direzioni]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Direzioni]
AS
SELECT     RIGHT(l.ProtocolloBando, 4) AS Anno, ISNULL(mf.mfIdMsg, 0) AS ID_MSG_PDA, l.ProtocolloBando, l.Oggetto, 
                      CASE CHARINDEX('<AFLinkFieldDirezioneProponente>', CAST(MSGTEXT AS VARCHAR(8000))) 
                      WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDirezioneProponente>', CAST(MSGTEXT AS VARCHAR(8000))) 
                      + 32, 400)) END AS DirezioneProponente, CAST(CASE CHARINDEX('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000))) 
                      WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 
                      400)) END AS float) AS ImportoBaseAsta, 
                      c.ImportoAggiudicato + c.OneriSic + c.OneriSicE + c.OneriSicI + c.OneriDis + c.LavoriEconomia AS ValoreContratto, m.msgText, 1 AS NumeroBandi, 
                      CASE CHARINDEX('<AFLinkFieldDataAperturaOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) 
                      WHEN 0 THEN '' ELSE LEFT(dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDataAperturaOfferte>', 
                      CAST(MSGTEXT AS VARCHAR(8000))) + 32, 400)), 4) END AS AnnoPrimaSeduta, c.ValutazioneEconomica
FROM         dbo.DASHBOARD_VIEW_BANDILAVORI AS l INNER JOIN
                      dbo.MessageFields AS mfBando ON mfBando.mfFieldName = 'IdDoc' AND mfBando.mfIdMsg = l.IdMsg LEFT OUTER JOIN
                      dbo.MessageFields AS mf ON mf.mfFieldName = 'IdDoc_BG' AND mf.mfFieldValue = mfBando.mfFieldValue AND mf.mfIsubType = 169 LEFT OUTER JOIN
                      dbo.Document_SchedaPrecontratto AS spc ON l.ProtocolloBando = spc.ProtocolloBando LEFT OUTER JOIN
                      dbo.TAB_MESSAGGI AS m ON m.IdMsg = l.IdMsg LEFT OUTER JOIN
                      dbo.Document_Com_Aggiudicataria AS c ON mf.mfIdMsg = c.ID_MSG_PDA
WHERE  RIGHT(l.ProtocolloBando, 4) NOT IN ('2007', '7/07') and spc.deleted=0


GO
