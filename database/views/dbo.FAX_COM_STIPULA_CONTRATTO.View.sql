USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FAX_COM_STIPULA_CONTRATTO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FAX_COM_STIPULA_CONTRATTO]
AS
SELECT     'I' AS LNG, dbo.Document_EsitoGara_Fornitori.idRow AS idDoc, Document_EsitoGara.id, Document_EsitoGara.DataCreazione, 
                      Document_EsitoGara.ID_MSG_PDA, Document_EsitoGara.ID_MSG_BANDO, Document_EsitoGara.StatoEsclusione, 
                      Document_EsitoGara.Oggetto, Document_EsitoGara.DataAperturaOfferte, Document_EsitoGara.DataIISeduta, 
                      Document_EsitoGara.Segretario, Document_EsitoGara.Protocol, Document_EsitoGara_Fornitori.idRow, 
                      Document_EsitoGara_Fornitori.idHeader, Document_EsitoGara_Fornitori.ProtocolloGenerale_Contratto, 
                      Document_EsitoGara_Fornitori.DataInvio, Document_EsitoGara_Fornitori.Fornitore, Document_EsitoGara_Fornitori.Motivazione, 
                      Document_EsitoGara_Fornitori.Stato, Document_EsitoGara_Fornitori.ID_MSG_OFFERTA, Document_EsitoGara_Fornitori.DataProt_Contratto, 
                      Document_EsitoGara_Fornitori.isATI
FROM         dbo.Document_EsitoGara INNER JOIN
                      dbo.Document_EsitoGara_Fornitori ON dbo.Document_EsitoGara.id = dbo.Document_EsitoGara_Fornitori.idHeader






GO
