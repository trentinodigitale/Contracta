USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Prosp_Attivita]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Prosp_Attivita] AS
select 	l.IdMsg ,
	l.ProtocolloBando, 
	l.Oggetto,  

	RIGHT(l.ProtocolloBando, 4) AS Anno ,
	left(l.DataAperturaOfferte, 4) AS AnnoPrimaSeduta ,
        l.DataAperturaOfferte,
     case when isdate(l.DataIISeduta)=1 THEN l.DataIISeduta 
          when isdate(CASE CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 25)) END)=1   then CASE CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 25)) END
      ELSE '' END AS DataIISeduta,
	ISNULL(mf.mfIdMsg, 0) AS ID_MSG_PDA, --> PDA
	1 as NumGarePubb
	,( cast(l.ImportoBaseAsta as float)) as ImportoBaseAsta
	,( case when mf.mfIdMsg is null then 0 
		else
			1 + CASE  WHEN ISDATE(l.DataIISeduta) = 1 THEN 1 
                                  WHEN ISDATE(CASE CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 25)) END)=1  AND ISDATE(l.DataIISeduta) = 0 THEN 1
                                  ELSE 0 
                            END
		END
	) as NumeroSeduteGara
	,c.ImportoAggiudicato + c.OneriSic + c.OneriSicE + c.OneriSicI + c.OneriDis + c.LavoriEconomia AS ValoreContratto
FROM         dbo.DASHBOARD_VIEW_BANDILAVORI AS l 
					INNER JOIN dbo.MessageFields AS mfBando ON mfBando.mfFieldName = 'IdDoc' AND mfBando.mfIdMsg = l.IdMsg 
					LEFT OUTER JOIN dbo.MessageFields AS mf ON mf.mfFieldName = 'IdDoc_BG' AND mf.mfFieldValue = mfBando.mfFieldValue AND mf.mfIsubType = 169 
					LEFT OUTER JOIN dbo.Document_Com_Aggiudicataria AS c ON mf.mfIdMsg = c.ID_MSG_PDA
                                        LEFT OUTER JOIN Tab_messaggi AS m ON m.idmsg=c.ID_MSG_PDA
WHERE  RIGHT(l.ProtocolloBando, 4) NOT IN ('2007', '7/07') 











GO
