USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_ADDFROM_BUDGET_DETAIL_BURKGURI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RDA_ADDFROM_BUDGET_DETAIL_BURKGURI]
AS
SELECT     CAST(dbo.Budget_Detail.BDD_id AS varchar) + 'aaa' + CAST(dbo.Document_Quotidiani.Id AS varchar) AS indrow, 
                      dbo.Budget_Detail.BDD_KeyVDS AS RDP_VDS, dbo.Budget_Detail.BDD_KeyMerceologia AS RDP_Merceologia, 
                      dbo.Budget_Detail.BDD_KeyProgetto AS RDP_Progetto, dbo.Budget_Detail.BDD_KeyFornitore AS RDP_Fornitore, 
                      dbo.Budget_Detail.BDD_KeyCodArtProd AS RDP_CodArtProd, dbo.Budget_Detail.BDD_KeyTipoInvestimento AS RDP_TipoInvestimento, 
                      dbo.Budget_Detail.BDD_Commessa AS RDP_Commessa, dbo.Budget_Detail.BDD_KeyPlant + '#~#' + dbo.Budget_Detail.BDD_KeyCDC AS Peg, 
                      ' ' + 'Peg' + ' ' + 'RDP_VDS' + ' ' + 'Giornale' + ' ' + 'Fornitore' + ' ' + 'NumMod' + ' ' + 'Importo' + ' ' + 'Disponibilita' + ' ' + 'StatoQuotidiano' + ' ' AS NonEditabili,
                       dbo.Document_Quotidiani.Id AS Giornale
FROM         dbo.Budget_Detail CROSS JOIN
                      dbo.Document_Quotidiani
WHERE     (dbo.Document_Quotidiani.Diffusione IN ('Burc', 'Guri'))

GO
