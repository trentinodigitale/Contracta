USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FAX_COM_ESCLUSIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FAX_COM_ESCLUSIONE]
AS
SELECT     'I' AS LNG, dbo.Document_Esclusione_Fornitori.idRow AS idDoc, dbo.Document_Esclusione.id, dbo.Document_Esclusione.DataCreazione, 
                      dbo.Document_Esclusione.ID_MSG_PDA, dbo.Document_Esclusione.ID_MSG_BANDO, dbo.Document_Esclusione.StatoEsclusione, 
                      dbo.Document_Esclusione.Oggetto, dbo.Document_Esclusione.DataAperturaOfferte, dbo.Document_Esclusione.DataIISeduta, 
                      dbo.Document_Esclusione.Segretario, dbo.Document_Esclusione.Protocol, dbo.Document_Esclusione_Fornitori.idRow, 
                      dbo.Document_Esclusione_Fornitori.idHeader, dbo.Document_Esclusione_Fornitori.ProtocolloGenerale, 
                      dbo.Document_Esclusione_Fornitori.DataInvio, dbo.Document_Esclusione_Fornitori.Fornitore, dbo.Document_Esclusione_Fornitori.Motivazione, 
                      dbo.Document_Esclusione_Fornitori.Stato, dbo.Document_Esclusione_Fornitori.ID_MSG_OFFERTA, dbo.Document_Esclusione_Fornitori.DataProt, 
                      dbo.Document_Esclusione_Fornitori.isATI
FROM         dbo.Document_Esclusione INNER JOIN
                      dbo.Document_Esclusione_Fornitori ON dbo.Document_Esclusione.id = dbo.Document_Esclusione_Fornitori.idHeader


GO
