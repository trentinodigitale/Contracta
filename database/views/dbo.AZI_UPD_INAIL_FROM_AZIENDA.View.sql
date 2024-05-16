USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_INAIL_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_UPD_INAIL_FROM_AZIENDA]
AS
SELECT     dbo.Aziende.aziRagioneSociale, dbo.Aziende.aziPartitaIVA, 
            DM_Attributi_0.vatValore_FT AS NumINAIL,
            DM_Attributi_1.vatValore_FT AS FaxINAIL,
			DM_Attributi_2.vatValore_FT AS TelefonoINAIL, 
			DM_Attributi_3.vatValore_FT AS SedeINAIL, 
            DM_Attributi_4.vatValore_FT AS UfficioINAIL, 
			DM_Attributi_5.vatValore_FT AS IndirizzoINAIL, 
			dbo.Aziende.IdAzi, 
                      dbo.Aziende.IdAzi AS ID_FROM
FROM         dbo.Aziende LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_3 ON dbo.Aziende.IdAzi = DM_Attributi_3.lnk AND DM_Attributi_3.idApp = 1 AND 
                      DM_Attributi_3.dztNome = 'SedeINAIL' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_4 ON dbo.Aziende.IdAzi = DM_Attributi_4.lnk AND DM_Attributi_4.idApp = 1 AND 
                      DM_Attributi_4.dztNome = 'UfficioINAIL' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_5 ON dbo.Aziende.IdAzi = DM_Attributi_5.lnk AND DM_Attributi_5.idApp = 1 AND 
                      DM_Attributi_5.dztNome = 'IndirizzoINAIL' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_2 ON dbo.Aziende.IdAzi = DM_Attributi_2.lnk AND DM_Attributi_2.idApp = 1 AND 
                      DM_Attributi_2.dztNome = 'TelefonoINAIL' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_1 ON dbo.Aziende.IdAzi = DM_Attributi_1.lnk AND DM_Attributi_1.idApp = 1 AND 
                      DM_Attributi_1.dztNome = 'FaxINAIL' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_0 ON dbo.Aziende.IdAzi = DM_Attributi_0.lnk AND DM_Attributi_0.idApp = 1 AND 
                      DM_Attributi_0.dztNome = 'NumINAIL' 


GO
