USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Prosp_sintesi]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Prosp_sintesi] AS
SELECT ISNULL(mf.mfIdMsg, 0) AS ID_MSG_PDA, l.ProtocolloBando, l.Oggetto, spc.Id AS idDocSchedaPrecontratto, 
						ISNULL(spc.idAggiudicatrice,  cg.idAggiudicatrice) AS Fornitore, dbo.Aziende.aziRagioneSociale, r.IdRepertorio, r.Rep, c.ResponsabileContratto, 
                      CASE CHARINDEX('<AFLinkFieldIncaricato>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, 
                      CHARINDEX('<AFLinkFieldIncaricato>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 400)) END AS IncaricatoBando
FROM         dbo.DASHBOARD_VIEW_BANDILAVORI AS l 
					INNER JOIN dbo.MessageFields AS mfBando ON mfBando.mfFieldName = 'IdDoc' AND mfBando.mfIdMsg = l.IdMsg 
					LEFT OUTER JOIN dbo.MessageFields AS mf ON mf.mfFieldName = 'IdDoc_BG' AND mf.mfFieldValue = mfBando.mfFieldValue AND mf.mfIsubType = 169 
					LEFT OUTER JOIN dbo.Document_Repertorio AS r ON l.ProtocolloBando = r.ProtocolloBando 
					LEFT OUTER JOIN dbo.Document_SchedaPrecontratto AS spc ON l.ProtocolloBando = spc.ProtocolloBando 
					LEFT OUTER JOIN dbo.Document_ControlliGara AS cg ON mf.mfIdMsg = cg.ID_MSG_PDA -- cg.ID_MSG_BANDO = l.IdMsg 
					LEFT OUTER JOIN dbo.Aziende ON dbo.Aziende.IdAzi = spc.idAggiudicatrice OR dbo.Aziende.IdAzi = cg.idAggiudicatrice 
					LEFT OUTER JOIN dbo.TAB_MESSAGGI AS m ON m.IdMsg = l.IdMsg 
					LEFT OUTER JOIN dbo.Document_Com_Aggiudicataria AS c ON mf.mfIdMsg = c.ID_MSG_PDA
where isnull(spc.deleted,0)=0 
and  RIGHT(l.ProtocolloBando, 4) NOT IN ('2007', '7/07')



GO
