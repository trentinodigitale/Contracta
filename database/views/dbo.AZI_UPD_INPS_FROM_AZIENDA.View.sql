USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_INPS_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_UPD_INPS_FROM_AZIENDA]
AS
SELECT Aziende.aziRagioneSociale
     , Aziende.aziPartitaIVA
     , DM_Attributi_0.vatValore_FT        AS NumINPS
     , DM_Attributi_1.vatValore_FT        AS FaxINPS
     , DM_Attributi_2.vatValore_FT        AS TelefonoINPS
     , DM_Attributi_3.vatValore_FT        AS SedeINPS
     , DM_Attributi_4.vatValore_FT        AS UfficioINPS
     , DM_Attributi_5.vatValore_FT        AS IndirizzoINPS
     --, DM_Attributi_6.vatValore_FT        AS SettoriCCNL
	 ,dbo.GetMultiValueAzi(IdAzi, 'SettoriCCNL') AS SettoriCCNL
     , Aziende.IdAzi
     , Aziende.IdAzi                      AS ID_FROM
  FROM Aziende 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_3 ON Aziende.IdAzi = DM_Attributi_3.lnk AND DM_Attributi_3.idApp = 1 AND DM_Attributi_3.dztNome = 'SedeINPS' 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_4 ON Aziende.IdAzi = DM_Attributi_4.lnk AND DM_Attributi_4.idApp = 1 AND DM_Attributi_4.dztNome = 'UfficioINPS' 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_5 ON Aziende.IdAzi = DM_Attributi_5.lnk AND DM_Attributi_5.idApp = 1 AND DM_Attributi_5.dztNome = 'IndirizzoINPS' 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_2 ON Aziende.IdAzi = DM_Attributi_2.lnk AND DM_Attributi_2.idApp = 1 AND DM_Attributi_2.dztNome = 'TelefonoINPS' 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_1 ON Aziende.IdAzi = DM_Attributi_1.lnk AND DM_Attributi_1.idApp = 1 AND DM_Attributi_1.dztNome = 'FaxINPS' 
  LEFT OUTER JOIN DM_Attributi AS DM_Attributi_0 ON Aziende.IdAzi = DM_Attributi_0.lnk AND DM_Attributi_0.idApp = 1 AND DM_Attributi_0.dztNome = 'NumINPS'
  --LEFT OUTER JOIN DM_Attributi AS DM_Attributi_6 ON Aziende.IdAzi = DM_Attributi_6.lnk AND DM_Attributi_6.idApp = 1 AND DM_Attributi_6.dztNome = 'SettoriCCNL'
GO
