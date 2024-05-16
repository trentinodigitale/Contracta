USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_CATEGORIE_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AZI_UPD_CATEGORIE_FROM_AZIENDA]
AS
SELECT     dbo.Aziende.aziRagioneSociale, dbo.Aziende.aziPartitaIVA, 
                      DM_Attributi_3.vatValore_FT AS CARClasMercAzienda, 
                      -- DM_Attributi_4.vatValore_FT AS GerarchicoSOA, 
                      -- DM_Attributi_4.vatValore_FT AS CategoriaSOA, 
                      -- DM_Attributi_5.vatValore_FT AS ATECO, 
                      dbo.GetMultiValueAzi(dbo.Aziende.IdAzi,'ClassificazioneSOA') as CategoriaSOA , 
                      dbo.GetMultiValueAzi(dbo.Aziende.IdAzi,'ClassificazioneSOA') as GerarchicoSOA , 
                      dbo.GetAtecoAzi(dbo.Aziende.IdAzi) as aziAtvAtecord , 
					  dbo.Aziende.IdAzi, 
                      dbo.Aziende.IdAzi AS ID_FROM
FROM         dbo.Aziende LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_3 ON dbo.Aziende.IdAzi = DM_Attributi_3.lnk AND DM_Attributi_3.idApp = 1 AND 
                      DM_Attributi_3.dztNome = 'CARClasMercAzienda' 
                      -- LEFT OUTER JOIN
                      -- dbo.DM_Attributi AS DM_Attributi_4 ON dbo.Aziende.IdAzi = DM_Attributi_4.lnk AND DM_Attributi_4.idApp = 1 AND 
                      -- DM_Attributi_4.dztNome = 'ClassificazioneSOA' 
                      -- LEFT OUTER JOIN
                      -- dbo.DM_Attributi AS DM_Attributi_5 ON dbo.Aziende.IdAzi = DM_Attributi_5.lnk AND DM_Attributi_5.idApp = 1 AND 
                      -- DM_Attributi_5.dztNome = 'ATECO'
                     


GO
