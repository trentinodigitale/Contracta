USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BUDGET_VIEWDetail_TOTAL]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BUDGET_VIEWDetail_TOTAL]
AS
SELECT     CASE WHEN RIGHT(bdd_keyvds, 6) >= '000900' THEN '1' ELSE '0' END AS BDD_Investimenti, 
                      dbo.BUDGET_CALCULATE.BDD_Importo * dbo.Budget_Valute.BDV_ValueDest AS BDD_Importo, dbo.Budget_Valute.BDV_CodiceValutaDest, 
                      dbo.BUDGET_CALCULATE.BDD_BDG_Periodo, dbo.BUDGET_CALCULATE.BDD_KeySOC, dbo.BUDGET_CALCULATE.BDD_KeyPlant, 
                      dbo.BUDGET_CALCULATE.BDD_KeyVDS, dbo.BUDGET_CALCULATE.BDD_KeyCDC, dbo.BUDGET_CALCULATE.BDD_KeyMerceologia, 
                      dbo.BUDGET_CALCULATE.BDD_KeyProgetto, dbo.BUDGET_CALCULATE.BDD_KeyFornitore, dbo.BUDGET_CALCULATE.BDD_KeyCodArtProd, 
                      dbo.BUDGET_CALCULATE.BDD_Commessa, dbo.BUDGET_CALCULATE.BDD_Check, dbo.BUDGET_CALCULATE.BDD_Level, 
                      dbo.BUDGET_CALCULATE.BDD_id, dbo.BUDGET_CALCULATE.BDD_KeySOCRic, dbo.BUDGET_CALCULATE.BDD_KeyPlantRic, 
                      - (dbo.BUDGET_CALCULATE.BDG_TOT_inProcess * dbo.Budget_Valute.BDV_ValueDest) AS BDG_TOT_inProcess, 
                      - (dbo.BUDGET_CALCULATE.BDG_TOT_Buyer * dbo.Budget_Valute.BDV_ValueDest) AS BDG_TOT_Buyer, 
                      - (dbo.BUDGET_CALCULATE.BDG_TOT_Ordered * dbo.Budget_Valute.BDV_ValueDest) AS BDG_TOT_Ordered, 
                      dbo.BUDGET_CALCULATE.BDG_TOT_Residuo * dbo.Budget_Valute.BDV_ValueDest AS BDG_TOT_Residuo, 
                      dbo.BUDGET_CALCULATE.BDG_TOT_Definizione * dbo.Budget_Valute.BDV_ValueDest AS BDG_TOT_Definizione, 
                      dbo.BUDGET_CALCULATE.BDD_KeyTipoInvestimento , '1' as BDG_ECONOMO
FROM         dbo.BUDGET_CALCULATE INNER JOIN
                      dbo.Budget_ValuteSocieta ON dbo.BUDGET_CALCULATE.BDD_KeySOC = dbo.Budget_ValuteSocieta.BDS_CodSoc AND 
                      dbo.BUDGET_CALCULATE.BDD_BDG_Periodo = dbo.Budget_ValuteSocieta.BDS_BDG_Periodo INNER JOIN
                      dbo.Budget_Valute ON dbo.Budget_ValuteSocieta.BDS_CodiceValuta = dbo.Budget_Valute.BDV_CodiceValutaSource AND 
                      dbo.Budget_ValuteSocieta.BDS_BDG_Periodo = dbo.Budget_Valute.BDV_BDG_Periodo

GO
