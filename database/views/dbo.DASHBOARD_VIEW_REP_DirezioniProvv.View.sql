USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_DirezioniProvv]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_DirezioniProvv]
AS
SELECT  RIGHT(l.ProtocolloBando, 4) AS Anno
      , ISNULL(mf.mfIdMsg, 0) AS ID_MSG_PDA
      , l.ProtocolloBando
      , l.Oggetto
      , CASE CHARINDEX('<AFLinkFieldDirezioneProponente>', CAST(m.msgText AS VARCHAR(8000))) 
                WHEN 0 THEN '' 
                ELSE dbo.GetField(SUBSTRING(m.msgText, CHARINDEX('<AFLinkFieldDirezioneProponente>', CAST(m.msgText AS VARCHAR(8000))) + 32, 400)) 
        END AS DirezioneProponente
      , CAST(CASE CHARINDEX('<AFLinkFieldImportoBaseAsta>', CAST(m.msgText AS VARCHAR(8000))) 
                WHEN 0 THEN '' 
                ELSE dbo.GetField(SUBSTRING(m.msgText, CHARINDEX('<AFLinkFieldImportoBaseAsta>', CAST(m.msgText AS VARCHAR(8000))) + 28, 400)) 
        END AS FLOAT) AS ImportoBaseAsta
      , v.ValoreContratto
      , 1 AS NumeroBandi
      , CASE CHARINDEX('<AFLinkFieldDataAperturaOfferte>', CAST(m.msgText AS VARCHAR(8000))) 
                WHEN 0 THEN '' 
                ELSE LEFT(dbo.GetField(SUBSTRING(m.msgText, CHARINDEX('<AFLinkFieldDataAperturaOfferte>', CAST(m.msgText AS VARCHAR(8000))) + 32, 30)), 4) 
        END AS AnnoPrimaSeduta
      , v.EconomicScoreClassic                                  AS ValutazioneEconomica
      , CASE CHARINDEX('<AFLinkFieldNRDeterminazione>', CAST(msgPDA.msgText AS VARCHAR(8000))) 
                WHEN 0 THEN '' 
                ELSE dbo.GetField(SUBSTRING(msgPDA.msgText, CHARINDEX('<AFLinkFieldNRDeterminazione>', CAST(msgPDA.msgText AS VARCHAR(8000))) + 29, 30))
        END AS NRDeterminazione
      , CASE CHARINDEX('<AFLinkFieldDataDetermina>', CAST(msgPDA.msgText AS VARCHAR(8000))) 
                WHEN 0 THEN '' 
                ELSE dbo.GetField(SUBSTRING(msgPDA.msgText, CHARINDEX('<AFLinkFieldDataDetermina>', CAST(msgPDA.msgText AS VARCHAR(8000))) + 26, 30))
        END AS DataDetermina
   FROM DASHBOARD_VIEW_BANDILAVORI AS l 
INNER JOIN MessageFields AS mfBando ON mfBando.mfFieldName = 'IdDoc' 
       AND mfBando.mfIdMsg = l.IdMsg 
 LEFT JOIN MessageFields AS mf ON mf.mfFieldName = 'IdDoc_BG' 
       AND mf.mfFieldValue = mfBando.mfFieldValue 
       AND mf.mfIsubType = 169 
 LEFT JOIN PDA_Valore_Contratto AS v ON v.IdPda = mf.mfIdMsg
 LEFT JOIN TAB_MESSAGGI AS msgPDA ON mf.mfIdmsg = msgPDA.IdMsg
 LEFT JOIN Document_SchedaPrecontratto AS spc ON l.ProtocolloBando = spc.ProtocolloBando 
 LEFT JOIN TAB_MESSAGGI AS m ON m.IdMsg = l.IdMsg 
 LEFT JOIN Document_Com_Aggiudicataria AS c ON mf.mfIdMsg = c.ID_MSG_PDA
where spc.deleted=0


GO
