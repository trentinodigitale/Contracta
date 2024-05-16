USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_RAPLEG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AZI_RAPLEG]
AS
SELECT IdAzi
     , aziRagioneSociale
     , aziPartitaIVA
     , DM_Attributi_0.vatValore_FT AS NomeRapLeg
     , DM_Attributi_1.vatValore_FT AS CognomeRapLeg
     , DM_Attributi_2.vatValore_FT AS TelefonoRapLeg
     , DM_Attributi_3.vatValore_FT AS EmailRapLeg
     , DM_Attributi_4.vatValore_FT AS RuoloRapLeg
     , DM_Attributi_5.vatValore_FT AS LocalitaRapLeg
     , DM_Attributi_6.vatValore_FT AS ProvinciaRapLeg
     , DM_Attributi_7.vatValore_FT AS DataRapLeg
     , DM_Attributi_8.vatValore_FT AS CellulareRapLeg
     , DM_Attributi_9.vatValore_FT AS CFRapLeg
  FROM Aziende 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_0 ON dbo.Aziende.IdAzi = DM_Attributi_0.lnk 
             AND DM_Attributi_0.idApp = 1 AND  DM_Attributi_0.dztNome = 'NomeRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_1 ON dbo.Aziende.IdAzi = DM_Attributi_1.lnk 
             AND DM_Attributi_1.idApp = 1 AND  DM_Attributi_1.dztNome = 'CognomeRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_2 ON dbo.Aziende.IdAzi = DM_Attributi_2.lnk 
             AND DM_Attributi_2.idApp = 1 AND  DM_Attributi_2.dztNome = 'TelefonoRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_3 ON dbo.Aziende.IdAzi = DM_Attributi_3.lnk 
             AND DM_Attributi_3.idApp = 1 AND  DM_Attributi_3.dztNome = 'EmailRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_4 ON dbo.Aziende.IdAzi = DM_Attributi_4.lnk 
             AND DM_Attributi_4.idApp = 1 AND  DM_Attributi_4.dztNome = 'RuoloRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_5 ON dbo.Aziende.IdAzi = DM_Attributi_5.lnk 
             AND DM_Attributi_5.idApp = 1 AND  DM_Attributi_5.dztNome = 'LocalitaRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_6 ON dbo.Aziende.IdAzi = DM_Attributi_6.lnk 
             AND DM_Attributi_6.idApp = 1 AND  DM_Attributi_6.dztNome = 'ProvinciaRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_7 ON dbo.Aziende.IdAzi = DM_Attributi_7.lnk 
             AND DM_Attributi_7.idApp = 1 AND  DM_Attributi_7.dztNome = 'DataRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_8 ON dbo.Aziende.IdAzi = DM_Attributi_8.lnk 
             AND DM_Attributi_1.idApp = 1 AND  DM_Attributi_8.dztNome = 'CellulareRapLeg' 
  LEFT OUTER JOIN  DM_Attributi AS DM_Attributi_9 ON dbo.Aziende.IdAzi = DM_Attributi_9.lnk 
             AND DM_Attributi_9.idApp = 1 AND  DM_Attributi_9.dztNome = 'CFRapLeg' 
GO
