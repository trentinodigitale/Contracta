USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_testata_scheda_controlli]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[View_testata_scheda_controlli]
AS
SELECT     IdAggiudicataria, c.IdRow, aziRagioneSociale, aziPartitaIVA, aziIndirizzoLeg, Ruolo, aziLocalitaLeg, IdAggiudicataria AS AGGIUDICAZIONE_AZIENDEGrid_ID_DOC, 
                      'CONTROLLISCHEDA' AS AGGIUDICAZIONE_AZIENDEGrid_OPEN_DOC_NAME,idazi as idazicontrollata,idazi,
			IdAggiudicataria AS IdSchedaGara,ProtocolloBando as protocol

FROM         Document_Progetti a,Document_Progetti_Lotti b,dbo.Document_Aggiudicatari_Lotto c
where        b.idrow=c.idrow and b.idprogetto=a.idprogetto


GO
