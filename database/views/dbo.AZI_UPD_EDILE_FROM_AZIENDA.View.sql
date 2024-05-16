USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_EDILE_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_UPD_EDILE_FROM_AZIENDA]
AS
SELECT      dbo.Aziende.aziRagioneSociale, 
			dbo.Aziende.aziPartitaIVA, 
			dbo.Aziende.IdAzi, 
            dbo.Aziende.IdAzi AS ID_FROM,

            DM_Attributi_0.vatValore_FT AS SedeEdile,
            DM_Attributi_1.vatValore_FT AS UfficioEdile,
			DM_Attributi_2.vatValore_FT AS IndirizzoEdile, 
			DM_Attributi_3.vatValore_FT AS TelefonoEdile, 
            DM_Attributi_4.vatValore_FT AS FaxEdile, 
			DM_Attributi_5.vatValore_FT AS NumEdile

FROM         dbo.Aziende LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_0 ON dbo.Aziende.IdAzi = DM_Attributi_0.lnk AND DM_Attributi_0.idApp = 1 AND 
                      DM_Attributi_0.dztNome = 'SedeEdile' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_1 ON dbo.Aziende.IdAzi = DM_Attributi_1.lnk AND DM_Attributi_1.idApp = 1 AND 
                      DM_Attributi_1.dztNome = 'UfficioEdile' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_2 ON dbo.Aziende.IdAzi = DM_Attributi_2.lnk AND DM_Attributi_2.idApp = 1 AND 
                      DM_Attributi_2.dztNome = 'IndirizzoEdile' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_3 ON dbo.Aziende.IdAzi = DM_Attributi_3.lnk AND DM_Attributi_3.idApp = 1 AND 
                      DM_Attributi_3.dztNome = 'TelefonoEdile' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_4 ON dbo.Aziende.IdAzi = DM_Attributi_4.lnk AND DM_Attributi_4.idApp = 1 AND 
                      DM_Attributi_4.dztNome = 'FaxEdile' LEFT OUTER JOIN
                      dbo.DM_Attributi AS DM_Attributi_5 ON dbo.Aziende.IdAzi = DM_Attributi_5.lnk AND DM_Attributi_5.idApp = 1 AND 
                      DM_Attributi_5.dztNome = 'NumEdile' 
GO
