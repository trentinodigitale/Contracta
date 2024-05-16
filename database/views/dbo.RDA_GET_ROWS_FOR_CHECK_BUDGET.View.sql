USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_GET_ROWS_FOR_CHECK_BUDGET]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[RDA_GET_ROWS_FOR_CHECK_BUDGET]
AS
SELECT     dbo.Document_RDA.RDA_ID, dbo.Document_RDA.RDA_AZI AS azienda, dbo.Document_RDA.RDA_Stato AS Stato, 
                      dbo.Document_RDA.RDA_Valuta AS Valuta, dbo.Document_RDA.RDA_BDG_Periodo AS Periodo, 
                      SUM(dbo.Document_RDA_Product.RDP_Importo * dbo.Document_RDA_Product.RDP_Qt) AS importo, dbo.Document_RDA.RDA_AZI AS KeySOC, 
                      SUBSTRING(dbo.Document_RDA.RDA_Plant_CDC, 1, 24) AS KeyPlant, SUBSTRING(dbo.Document_RDA.RDA_Plant_CDC, 28, 50) AS KeyCDC, 
                      dbo.Document_RDA_Product.RDP_VDS AS KeyVDS, dbo.Document_RDA_Product.RDP_Merceologia AS KeyMerceologia, 
                      dbo.Document_RDA_Product.RDP_Progetto AS KeyProgetto, dbo.Document_RDA_Product.RDP_Fornitore AS KeyFornitore, 
                      dbo.Document_RDA_Product.RDP_CodArtProd AS KeyCodArtProd, dbo.Document_RDA_Product.RDP_TipoInvestimento AS KeyTipoInvestimento, 
                      dbo.Document_RDA.RDA_SOCRic AS KeySocRic, SUBSTRING(dbo.Document_RDA.RDA_PlantRic, 1, 24) AS KeyPlantRic, 
                      YEAR(dbo.Document_RDA_Product.RDP_DataPrevCons) AS RDP_DataPrevCons, dbo.Document_RDA_Product.RDP_cpi, 
                      dbo.Document_RDA_Product.RDP_rprot, dbo.Document_RDA.RDA_PlantRic
FROM         dbo.Document_RDA INNER JOIN
                      dbo.Document_RDA_Product ON dbo.Document_RDA.RDA_ID = dbo.Document_RDA_Product.RDP_RDA_ID
GROUP BY dbo.Document_RDA.RDA_ID, dbo.Document_RDA.RDA_AZI, dbo.Document_RDA.RDA_Stato, dbo.Document_RDA.RDA_Valuta, 
                      dbo.Document_RDA.RDA_BDG_Periodo, dbo.Document_RDA.RDA_AZI, SUBSTRING(dbo.Document_RDA.RDA_Plant_CDC, 1, 24), 
                      SUBSTRING(dbo.Document_RDA.RDA_Plant_CDC, 28, 50), dbo.Document_RDA_Product.RDP_VDS, dbo.Document_RDA_Product.RDP_Merceologia, 
                      dbo.Document_RDA_Product.RDP_Progetto, dbo.Document_RDA_Product.RDP_Fornitore, dbo.Document_RDA_Product.RDP_CodArtProd, 
                      dbo.Document_RDA_Product.RDP_TipoInvestimento, dbo.Document_RDA.RDA_SOCRic, SUBSTRING(dbo.Document_RDA.RDA_PlantRic, 1, 24), 
                      YEAR(dbo.Document_RDA_Product.RDP_DataPrevCons), dbo.Document_RDA_Product.RDP_cpi, dbo.Document_RDA_Product.RDP_rprot, 
                      dbo.Document_RDA.RDA_PlantRic




GO
