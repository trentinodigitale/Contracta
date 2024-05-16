USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_GET_ROWS_CHECK_RESIDUAL]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[RDA_GET_ROWS_CHECK_RESIDUAL]
AS
SELECT     RDP_idRow, RDP_Importo * RDP_Qt AS Importo, RDP_ResidualBudget AS Residuo, RDP_VDS AS KeyVDS, RDP_Merceologia AS KeyMerceologia, 
                      RDP_Progetto AS KeyProgetto, RDP_Fornitore AS KeyFornitore, RDP_CodArtProd AS KeyCodArtProd, 
                      RDP_TipoInvestimento AS KeyTipoInvestimento
FROM         dbo.Document_RDA_Product



GO
