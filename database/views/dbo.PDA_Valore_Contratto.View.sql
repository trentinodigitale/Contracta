USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_Valore_Contratto]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PDA_Valore_Contratto]
AS

SELECT a.IdPda
     , CAST(a.EconomicScoreClassic AS FLOAT)            AS EconomicScoreClassic
     , CAST(c.ImportiVari AS FLOAT)                     AS ImportoAggiudicato
     , CAST(b.Oneri AS FLOAT)                           AS Oneri
     , CAST(b.Oneri AS FLOAT) + ROUND(CAST(c.ImportiVari AS FLOAT) 
                              - (CAST(c.ImportiVari AS FLOAT) * CAST(a.EconomicScoreClassic AS FLOAT) / 100), 2)
                                                        AS ValoreContratto
  FROM Document_PDA_Aziende a
     , Document_PDA_Importi c
     , (SELECT IdPdA
             , SUM(CAST(ImportiVari AS FLOAT))          AS Oneri
          FROM Document_PDA_Importi
         WHERE DescrImportiVari IN ('02', '03', '04', '05', '06')
        GROUP BY IdPdA) b
 WHERE a.IdPda = b.IdPda
   AND a.IdPda = c.IdPda
   AND c.DescrImportiVari = '01'
   AND a.StatoPda = 5
     
GO
