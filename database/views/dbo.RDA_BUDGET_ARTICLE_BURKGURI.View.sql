USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_BUDGET_ARTICLE_BURKGURI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RDA_BUDGET_ARTICLE_BURKGURI]
AS
SELECT     '1' AS RDA_TYPE, CAST(dbo.Budget_Detail.BDD_id AS varchar) + 'aaa' + CAST(dbo.Document_Quotidiani.Id AS varchar) AS BDD_ID, 
                      dbo.Budget_Detail.BDD_Commessa, dbo.Budget_Detail.BDD_Importo, SUM(dbo.Budget_Movement.BDM_Importo) AS RDA_ResidualBudget, 
                      dbo.Budget_Detail.BDD_KeyFornitore AS RDP_Fornitore_Filter, dbo.Budget_Detail.BDD_BDG_Periodo AS RDA_BDG_Periodo, 
                      dbo.Budget_Detail.BDD_KeyPlant + N'#~#' + dbo.Budget_Detail.BDD_KeyCDC AS RDA_Plant_CDC, dbo.Budget_Detail.BDD_KeySOC, 
                      dbo.Budget_Detail.BDD_KeyPlant, dbo.Budget_Detail.BDD_KeyVDS, dbo.Budget_Detail.BDD_KeyCDC, dbo.Budget_Detail.BDD_KeyMerceologia, 
                      dbo.Budget_Detail.BDD_KeyProgetto, dbo.Budget_Detail.BDD_KeyFornitore, dbo.Budget_Detail.BDD_KeyCodArtProd, 
                      dbo.Budget_Detail.BDD_KeyTipoInvestimento, dbo.Budget_Detail.BDD_KeySOCRic, dbo.Budget_Detail.BDD_KeyPlantRic, 
                      dbo.Budget_Detail.BDD_BDG_Periodo, dbo.Budget_Detail.BDD_KeyPlantRic AS RDA_PlantRic, 
                      dbo.Budget_Detail.BDD_KeyPlant + N'#~#' + dbo.Budget_Detail.BDD_KeyCDC AS Peg, dbo.Document_Quotidiani.Id AS Giornale, 
                      dbo.Document_Quotidiani.Diffusione, dbo.Document_Quotidiani.Quotidiano
FROM         dbo.Budget_Movement INNER JOIN
                      dbo.Budget_Detail ON dbo.Budget_Movement.BDM_BDG_Periodo = dbo.Budget_Detail.BDD_BDG_Periodo AND 
                      dbo.Budget_Movement.BDM_KeySOC = dbo.Budget_Detail.BDD_KeySOC AND 
                      dbo.Budget_Movement.BDM_KeyPlant = dbo.Budget_Detail.BDD_KeyPlant AND 
                      dbo.Budget_Movement.BDM_KeyVDS = dbo.Budget_Detail.BDD_KeyVDS AND 
                      dbo.Budget_Movement.BDM_KeyCDC = dbo.Budget_Detail.BDD_KeyCDC AND 
                      dbo.Budget_Movement.BDM_KeyMerceologia = dbo.Budget_Detail.BDD_KeyMerceologia AND 
                      dbo.Budget_Movement.BDM_KeyProgetto = dbo.Budget_Detail.BDD_KeyProgetto AND 
                      dbo.Budget_Movement.BDM_KeyFornitore = dbo.Budget_Detail.BDD_KeyFornitore AND 
                      dbo.Budget_Movement.BDM_KeyCodArtProd = dbo.Budget_Detail.BDD_KeyCodArtProd AND 
                      dbo.Budget_Movement.BDM_KeyTipoInvestimento = dbo.Budget_Detail.BDD_KeyTipoInvestimento AND 
                      dbo.Budget_Movement.BDM_KeySOCRic = dbo.Budget_Detail.BDD_KeySOCRic AND 
                      dbo.Budget_Movement.BDM_KeyPlantRic = dbo.Budget_Detail.BDD_KeyPlantRic CROSS JOIN
                      dbo.Document_Quotidiani
WHERE     (dbo.Budget_Movement.BDM_isOld = 0) AND (dbo.Budget_Detail.BDD_BDG_Periodo IN
                          (SELECT     BDG_Periodo
                            FROM          dbo.Budget_Anag
                            WHERE      (BDG_Stato = 'esercizio'))) AND (dbo.Budget_Detail.BDD_KeyVDS IN ('1326', '1706')) AND (dbo.Document_Quotidiani.Diffusione IN ('Burc', 
                      'Guri'))
GROUP BY dbo.Budget_Detail.BDD_KeySOC, dbo.Budget_Detail.BDD_KeyPlant, dbo.Budget_Detail.BDD_KeyVDS, 
                      dbo.Budget_Detail.BDD_KeyPlant + N'#~#' + dbo.Budget_Detail.BDD_KeyCDC, dbo.Budget_Detail.BDD_KeyCDC, 
                      dbo.Budget_Detail.BDD_KeyMerceologia, dbo.Budget_Detail.BDD_KeyProgetto, dbo.Budget_Detail.BDD_KeyFornitore, 
                      dbo.Budget_Detail.BDD_KeyCodArtProd, dbo.Budget_Detail.BDD_KeyTipoInvestimento, dbo.Budget_Detail.BDD_KeySOCRic, 
                      dbo.Budget_Detail.BDD_KeyPlantRic, dbo.Budget_Detail.BDD_BDG_Periodo, CAST(dbo.Budget_Detail.BDD_id AS varchar) 
                      + 'aaa' + CAST(dbo.Document_Quotidiani.Id AS varchar), dbo.Budget_Detail.BDD_Commessa, dbo.Budget_Detail.BDD_Importo, 
                      dbo.Document_Quotidiani.Id, dbo.Document_Quotidiani.Diffusione, dbo.Document_Quotidiani.Quotidiano

GO
