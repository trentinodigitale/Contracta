USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RTI_SelectNewAZI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[RTI_SelectNewAZI]
AS
SELECT     dbo.Aziende.IdAzi AS indrow, dbo.Aziende.IdAzi AS idAziPartecipante, dbo.Aziende.aziRagioneSociale, azipartitaiva,vatValore_FV,
                      CASE WHEN vatValore_FV <> aziPartitaIVA THEN aziPartitaIVA + ' / ' + vatValore_FV ELSE aziPartitaIVA END AS PIVA_CF,dbo.Aziende.IdAzi  as idAziEsecutrice,
		aziIndirizzoLeg,aziLocalitaLeg,idazi

FROM         dbo.Aziende left outer JOIN   dbo.DM_Attributi ON dbo.Aziende.IdAzi = dbo.DM_Attributi.lnk 
      AND (dbo.DM_Attributi.dztNome = 'codicefiscale')AND (dbo.DM_Attributi.idApp = 1) 
WHERE     (dbo.Aziende.aziVenditore = 2)

GO
