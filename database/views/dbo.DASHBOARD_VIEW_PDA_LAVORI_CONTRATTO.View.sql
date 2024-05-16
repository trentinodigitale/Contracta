USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PDA_LAVORI_CONTRATTO]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_PDA_LAVORI_CONTRATTO]  AS
SELECT IdMsg
				 , umIdPfu AS IdPfu
				 , msgIType
				 , msgISubType
				 , msgelabwithsuccess
				 , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
				   END AS Name
				 , CASE CHARINDEX ('<AFLinkFieldNameBG>', CAST(MSGTEXT AS VARCHAR(8000))) 
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNameBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 400)) 
				   END AS NameBG
				 , CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
				   END AS ProtocolloBando
				 , CASE CHARINDEX ('<AFLinkFieldDataAperturaOfferte>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataAperturaOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) + 32, 25)) 
				   END AS DataAperturaOfferte
				 , CASE CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 25)) 
				   END AS DataIISeduta

				 , SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 1) AS StatoGD
				 , CASE CHARINDEX ('<AFLinkFieldNumeroIndizione>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNumeroIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
				   END AS NumeroIndizione
				, CASE CHARINDEX ('<AFLinkFieldDataIndizione>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 25)) 
				   END AS DataIndizione

				 , CASE CHARINDEX ('<AFLinkFieldNumeroGP>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNumeroGP>', CAST(MSGTEXT AS VARCHAR(8000))) + 21, 25)) 
				   END AS NumeroGP
				, CASE CHARINDEX ('<AFLinkFieldDataGP>', CAST(MSGTEXT AS VARCHAR(8000)))
						WHEN 0 THEN ''
						ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataGP>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 25)) 
				   END AS DataGP

			  FROM TAB_MESSAGGI
				 , TAB_UTENTI_MESSAGGI
			 WHERE IdMsg = umIdMsg
			   AND msgItype = 55
			   AND msgisubtype = 169
			   AND umInput = 0
			   AND umStato = 0
			   AND umIdPfu <> -10
GO
