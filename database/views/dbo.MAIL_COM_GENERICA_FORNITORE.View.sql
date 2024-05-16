USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_COM_GENERICA_FORNITORE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_COM_GENERICA_FORNITORE]
AS
SELECT 'I' AS LNG, dbo.Document_Comunicazione_Fornitori.idRow AS idDoc
     , Document_Comunicazione.id
     , Document_Comunicazione.DataCreazione
     , Document_Comunicazione.ID_MSG_Tabulato
     , Document_Comunicazione.ID_MSG_BANDO
     , Document_Comunicazione.StatoEsclusione
     , Document_Comunicazione.Oggetto
     , Document_Comunicazione.Segretario
     , Document_Comunicazione.Protocol
     , Document_Comunicazione_Fornitori.idRow
     , Document_Comunicazione_Fornitori.idHeader
     , Document_Comunicazione_Fornitori.ProtocolloGenerale
     , convert ( varchar(10),Document_Comunicazione_Fornitori.DataInvio,103) as DataInvio
     , Document_Comunicazione_Fornitori.Fornitore
     , Document_Comunicazione_Fornitori.Stato
     , Document_Comunicazione_Fornitori.DataProt
     , Document_Comunicazione_Fornitori.isATI
  FROM   dbo.Document_Comunicazione INNER JOIN
                      dbo.Document_Comunicazione_Fornitori ON dbo.Document_Comunicazione.id = dbo.Document_Comunicazione_Fornitori.idHeader

GO
