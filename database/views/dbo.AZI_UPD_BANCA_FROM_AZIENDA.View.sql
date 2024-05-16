USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_BANCA_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_UPD_BANCA_FROM_AZIENDA]
AS
SELECT      dbo.Aziende.aziRagioneSociale, 
			dbo.Aziende.aziPartitaIVA, 
			dbo.Aziende.IdAzi, 
            dbo.Aziende.IdAzi AS ID_FROM,

            DM_Attributi_0.vatValore_FT AS Banca,
            DM_Attributi_1.vatValore_FT AS AgenziaBanca,
			DM_Attributi_2.vatValore_FT AS CittaBanca, 
			DM_Attributi_3.vatValore_FT AS ProvBanca, 
            DM_Attributi_4.vatValore_FT AS ABIBanca, 
			DM_Attributi_5.vatValore_FT AS CABBanca, 
			DM_Attributi_6.vatValore_FT AS CINBanca, 
			DM_Attributi_7.vatValore_FT AS CCBanca, 
			DM_Attributi_8.vatValore_FT AS IBAANBanca 

FROM         dbo.Aziende LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_0 ON dbo.Aziende.IdAzi = DM_Attributi_0.lnk AND DM_Attributi_0.idApp = 1 AND 
                      DM_Attributi_0.dztNome = 'Banca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_1 ON dbo.Aziende.IdAzi = DM_Attributi_1.lnk AND DM_Attributi_1.idApp = 1 AND 
                      DM_Attributi_1.dztNome = 'AgenziaBanca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_2 ON dbo.Aziende.IdAzi = DM_Attributi_2.lnk AND DM_Attributi_2.idApp = 1 AND 
                      DM_Attributi_2.dztNome = 'CittaBanca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_3 ON dbo.Aziende.IdAzi = DM_Attributi_3.lnk AND DM_Attributi_3.idApp = 1 AND 
                      DM_Attributi_3.dztNome = 'ProvBanca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_4 ON dbo.Aziende.IdAzi = DM_Attributi_4.lnk AND DM_Attributi_4.idApp = 1 AND 
                      DM_Attributi_4.dztNome = 'ABIBanca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_5 ON dbo.Aziende.IdAzi = DM_Attributi_5.lnk AND DM_Attributi_5.idApp = 1 AND 
                      DM_Attributi_5.dztNome = 'CABBanca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_6 ON dbo.Aziende.IdAzi = DM_Attributi_6.lnk AND DM_Attributi_6.idApp = 1 AND 
                      DM_Attributi_6.dztNome = 'CINBanca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_7 ON dbo.Aziende.IdAzi = DM_Attributi_7.lnk AND DM_Attributi_7.idApp = 1 AND 
                      DM_Attributi_7.dztNome = 'CCBanca' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_8 ON dbo.Aziende.IdAzi = DM_Attributi_8.lnk AND DM_Attributi_8.idApp = 1 AND 
                      DM_Attributi_8.dztNome = 'IBAANBanca' 


GO
