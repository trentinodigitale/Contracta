USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_CCIAA_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_UPD_CCIAA_FROM_AZIENDA]
AS
SELECT     dbo.Aziende.aziRagioneSociale, dbo.Aziende.aziPartitaIVA, dbo.DM_Attributi.vatValore_FT AS ANNOCOSTITUZIONE, 
                      DM_Attributi_1.vatValore_FT AS IscrCCIAA, DM_Attributi_2.vatValore_FT AS SedeCCIAA, DM_Attributi_3.vatValore_FT AS NotaIscrizioneCCIAA, 
                      DM_Attributi_4.vatValore_FT AS Persgiuridica, DM_Attributi_5.vatValore_FT AS QualitaImprenditore, dbo.Aziende.IdAzi, 
                      dbo.Aziende.IdAzi AS ID_FROM
FROM         dbo.Aziende LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_3 ON dbo.Aziende.IdAzi = DM_Attributi_3.lnk AND DM_Attributi_3.idApp = 1 AND 
                      DM_Attributi_3.dztNome = 'NotaIscrizioneCCIAA' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_4 ON dbo.Aziende.IdAzi = DM_Attributi_4.lnk AND DM_Attributi_4.idApp = 1 AND 
                      DM_Attributi_4.dztNome = 'Persgiuridica' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_5 ON dbo.Aziende.IdAzi = DM_Attributi_5.lnk AND DM_Attributi_5.idApp = 1 AND 
                      DM_Attributi_5.dztNome = 'QualitaImprenditore' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_2 ON dbo.Aziende.IdAzi = DM_Attributi_2.lnk AND DM_Attributi_2.idApp = 1 AND 
                      DM_Attributi_2.dztNome = 'SedeCCIAA' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_1 ON dbo.Aziende.IdAzi = DM_Attributi_1.lnk AND DM_Attributi_1.idApp = 1 AND 
                      DM_Attributi_1.dztNome = 'IscrCCIAA' LEFT OUTER JOIN
                      dbo.DM_Attributi ON dbo.Aziende.IdAzi = dbo.DM_Attributi.lnk AND DM_Attributi.idApp = 1 AND dbo.DM_Attributi.dztNome = 'ANNOCOSTITUZIONE'

GO
