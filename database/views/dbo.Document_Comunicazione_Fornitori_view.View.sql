USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Comunicazione_Fornitori_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Document_Comunicazione_Fornitori_view]
AS
SELECT Id
     , DataCreazione
     , ID_MSG_Tabulato
     , ID_MSG_BANDO
     , StatoEsclusione
     , Oggetto
     , Segretario
     , Protocol
     , IdRow
     , IdHeader
     , CASE WHEN ISNULL(Document_Comunicazione_Fornitori.ProtocolloGenerale, '') = '' THEN Document_Comunicazione.ProtocolloGenerale 
            ELSE Document_Comunicazione_Fornitori.ProtocolloGenerale 
       END AS ProtocolloGenerale
     , DataInvio
     , Fornitore
     , Stato
     , CASE WHEN Document_Comunicazione_Fornitori.DataProt IS NULL THEN Document_Comunicazione.DataProt 
            ELSE Document_Comunicazione_Fornitori.DataProt 
       END AS DataProt
     , IdRow AS DETTAGLIGrid_ID_DOC 
     , 'COM_GENERICA_FORNITORE' AS DETTAGLIGrid_OPEN_DOC_NAME 
     , isATI
     , NoteProgetto
     , Allegato
     , aziRagioneSociale
  FROM Document_Comunicazione 
     , Document_Comunicazione_Fornitori
     , Aziende
 WHERE Id = IdHeader
   AND Fornitore = IdAzi


GO
