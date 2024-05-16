USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_aggiudicatarie_scheda]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[view_aggiudicatarie_scheda]
AS
SELECT     IdAggiudicataria, c.IdRow, aziRagioneSociale, aziPartitaIVA, aziIndirizzoLeg, Ruolo, aziLocalitaLeg, TipoAggiudicataria,IdAggiudicataria AS AGGIUDICAZIONE_AZIENDEGrid_ID_DOC, 
                      'CONTROLLISCHEDA' AS AGGIUDICAZIONE_AZIENDEGrid_OPEN_DOC_NAME,idazi as idazicontrollata,idazi,
			IdAggiudicataria AS IdSchedaGara

FROM         dbo.Document_Aggiudicatari_Lotto c


GO
