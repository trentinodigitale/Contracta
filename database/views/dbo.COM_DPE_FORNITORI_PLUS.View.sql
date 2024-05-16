USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_FORNITORI_PLUS]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[COM_DPE_FORNITORI_PLUS]
AS

SELECT IdAzi 
     , aziRagioneSociale 
     , a.vatvalore_FT AS CARBelongTO
     , aziPartitaIVA
     , c.vatvalore_ft AS ClasseIscriz
     , aziIndirizzoLeg + ' - ' + aziLocalitaLeg + ' - ' + aziStatoLeg AS Indirizzo
  FROM Aziende 
 INNER JOIN MPAziende ON IdAzi = mpaIdAzi AND mpaIdMp = 1 AND mpaDeleted = 0
 INNER JOIN DM_Attributi a ON a.lnk = IdAzi AND a.idapp= 1 AND a.dztNome = 'CARBelongTO'
  LEFT JOIN  DM_Attributi c ON c.lnk = IdAzi AND c.idapp = 1 AND c.dztNome = 'ClasseIscriz'
 WHERE aziDeleted = 0

GO
