USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_RAPLEG_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_UPD_RAPLEG_FROM_AZIENDA]
AS
SELECT v.aziRagioneSociale
     , v.aziPartitaIVA
     , v.IdAzi
     , v.IdAzi AS ID_FROM
     , v.LocalitaRapLeg
     , v.CellulareRapLeg
     , v.TelefonoRapLeg
     , v.CognomeRapLeg
     , v.NomeRapLeg
     , v.RuoloRapLeg
     , v.ProvinciaRapLeg
     , case when isdate( v.DataRapLeg ) = 1 then convert( datetime , v.DataRapLeg  ) else null end as DataRapLeg 
     , v.EmailRapLeg
     , NULL AS IdRow
     , v.CFRapLeg
     , '' AS ResidenzaRapLeg
  FROM AZI_RAPLEG AS v 
 WHERE v.IdAzi NOT IN (SELECT IdAziRapLeg FROM Document_Aziende_RapLeg WHERE IsOld = 0 AND IdAziRapLeg IS NOT NULL)
-- WHERE CAST(v.IdAzi AS VARCHAR) + ISNULL(v.CognomeRapLeg, '') + ISNULL(v.NomeRapLeg, '') NOT IN (SELECT CAST(IdAziRapLeg AS VARCHAR)  + ISNULL(CognomeRapLeg, '') + ISNULL(NomeRapLeg, '') FROM Document_Aziende_RapLeg WHERE IsOld = 0 AND IdAziRapLeg IS NOT NULL)
UNION
SELECT a.aziRagioneSociale
     , a.aziPartitaIVA
     , a.IdAzi
     , a.IdAzi AS ID_FROM
     , s.LocalitaRapLeg
     , s.CellulareRapLeg
     , s.TelefonoRapLeg
     , s.CognomeRapLeg
     , s.NomeRapLeg
     , s.RuoloRapLeg
     , s.ProvinciaRapLeg
     , case when isdate( s.DataRapLeg ) = 1 then convert( datetime , s.DataRapLeg  ) else null end as DataRapLeg 
     --, s.EmailRapLeg
      ,ISNULL(vatValore_FT,'') as EmailRapLeg
     , s.idRow
     , s.CFRapLeg
     , s.ResidenzaRapLeg
  FROM Aziende AS a 
  INNER JOIN Document_Aziende_RapLeg AS s ON a.IdAzi = s.idAziRapLeg AND s.isOld = 0
  LEFT JOIN DM_ATTRIBUTI AS DA on s.idAziRapLeg=DA.lnk and dztNome='EmailRapLeg'
GO
