USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_ADDFROM_BUDGET_DETAIL]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RDA_ADDFROM_BUDGET_DETAIL]
AS
SELECT     BDD_id AS indrow, BDD_KeyVDS AS RDP_VDS, BDD_KeyMerceologia AS RDP_Merceologia, BDD_KeyProgetto AS RDP_Progetto, 
                      BDD_KeyFornitore AS RDP_Fornitore, BDD_KeyCodArtProd AS RDP_CodArtProd, BDD_KeyTipoInvestimento AS RDP_TipoInvestimento, 
                      BDD_Commessa AS RDP_Commessa, BDD_KeyPlant + '#~#' + BDD_KeyCDC AS Peg, 
                      ' ' + 'Peg' + ' ' + 'RDP_VDS' + ' ' + 'Giornale' + ' ' + 'Fornitore' + ' ' + 'NumMod' + ' ' + 'Importo' + ' ' + 'Disponibilita' + ' ' + 'StatoQuotidiano' + ' ' AS NonEditabili
FROM         dbo.Budget_Detail


GO
