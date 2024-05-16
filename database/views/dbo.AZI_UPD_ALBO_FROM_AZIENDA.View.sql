USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_ALBO_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AZI_UPD_ALBO_FROM_AZIENDA]
AS
SELECT aziRagioneSociale
     , aziPartitaIVA
     , DM_Attributi_3.vatValore_FT AS ProtGen
     , dbo.GetDateValueAzi(IdAzi, 'DataProt') AS DataProt
     , dbo.GetMultiValueAzi(IdAzi, 'ClasseIscriz') AS ClasseIscriz
     , dbo.GetDateValueAzi(IdAzi, 'sysHabilitStartDate') AS sysHabilitStartDate
     , DM_Attributi_7.vatValore_FT AS CARBelongTo
     , DM_Attributi_8.vatValore_FT AS AltraClassificazione
     , DM_Attributi_9.vatValore_FT AS CancellatoDiUfficio
     , IdAzi
     , IdAzi AS ID_FROM
     , dbo.GetMultiValueAzi(IdAzi, 'ClassificazioneSOA') AS GerarchicoSOA
  FROM Aziende 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_3 ON IdAzi = DM_Attributi_3.lnk AND DM_Attributi_3.idApp = 1 AND 
                      DM_Attributi_3.dztNome = 'ProtGen' 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_7 ON IdAzi = DM_Attributi_7.lnk AND DM_Attributi_7.idApp = 1 AND 
                      DM_Attributi_7.dztNome = 'CARBelongTo' 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_8 ON IdAzi = DM_Attributi_8.lnk AND DM_Attributi_8.idApp = 1 AND 
                      DM_Attributi_8.dztNome = 'AltraClassificazione'
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_9 ON IdAzi = DM_Attributi_9.lnk AND DM_Attributi_9.idApp = 1 AND 
                      DM_Attributi_9.dztNome = 'CancellatoDiUfficio'

GO
