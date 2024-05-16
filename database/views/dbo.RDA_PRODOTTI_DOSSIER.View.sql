USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_PRODOTTI_DOSSIER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[RDA_PRODOTTI_DOSSIER]
AS
SELECT     b.RDP_RDA_ID, b.RDP_idRow, b.RDP_CodArtProd AS [Codice Articolo], a.RDA_Plant_CDC AS sedidest, a.RDA_Valuta AS CARValGenerico, 
                      a.RDA_Utilizzo AS carutilizzo, b.RDP_Qt AS CARQuantitaDaOrdinare, b.RDP_Importo AS PrzUnOfferta, 
                      b.RDP_DataPrevCons AS CARDataConsegnaProdotto, b.RDP_Desc AS [descrizione articolo]
FROM         dbo.Document_RDA_Product b INNER JOIN
                      dbo.Document_RDA a ON b.RDP_RDA_ID = a.RDA_ID




GO
