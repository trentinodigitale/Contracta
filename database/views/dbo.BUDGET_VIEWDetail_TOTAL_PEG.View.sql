USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BUDGET_VIEWDetail_TOTAL_PEG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[BUDGET_VIEWDetail_TOTAL_PEG]
AS
SELECT     
--CASE WHEN RIGHT(bdd_keyvds, 6) >= '000900' THEN '1' ELSE '0' END AS BDD_Investimenti, 
                      dbo.BUDGET_CALCULATE_PEG.BDD_Importo * dbo.Budget_Valute.BDV_ValueDest AS BDD_Importo, 
					  dbo.Budget_Valute.BDV_CodiceValutaDest, 
                      dbo.BUDGET_CALCULATE_PEG.BDD_BDG_Periodo, 
					  dbo.BUDGET_CALCULATE_PEG.BDD_KeyEnte, 
					  dbo.BUDGET_CALCULATE_PEG.BDD_KeyArea, 
                      dbo.BUDGET_CALCULATE_PEG.BDD_KeyCDR, 
					  dbo.BUDGET_CALCULATE_PEG.BDD_KeyUAC,
					  dbo.BUDGET_CALCULATE_PEG.BDD_KeyPegCDC,
					  dbo.BUDGET_CALCULATE_PEG.BDD_KeyCodIntervento,
					  dbo.BUDGET_CALCULATE_PEG.BDD_KeyProgetto, 
					  dbo.BUDGET_CALCULATE_PEG.BDD_KeyCapitolo, 
                      dbo.BUDGET_CALCULATE_PEG.BDD_Check, dbo.BUDGET_CALCULATE_PEG.BDD_Level, 
                      dbo.BUDGET_CALCULATE_PEG.BDD_id, 
                      - (dbo.BUDGET_CALCULATE_PEG.BDG_TOT_inProcess * dbo.Budget_Valute.BDV_ValueDest) AS BDG_TOT_inProcess, 
                      - (dbo.BUDGET_CALCULATE_PEG.BDG_TOT_Buyer * dbo.Budget_Valute.BDV_ValueDest) AS BDG_TOT_Buyer, 
                      - (dbo.BUDGET_CALCULATE_PEG.BDG_TOT_Ordered * dbo.Budget_Valute.BDV_ValueDest) AS BDG_TOT_Ordered, 
                      dbo.BUDGET_CALCULATE_PEG.BDG_TOT_Residuo * dbo.Budget_Valute.BDV_ValueDest AS BDG_TOT_Residuo, 
                      dbo.BUDGET_CALCULATE_PEG.BDG_TOT_Definizione * dbo.Budget_Valute.BDV_ValueDest AS BDG_TOT_Definizione
                      
FROM         dbo.BUDGET_CALCULATE_PEG INNER JOIN
                      dbo.Budget_ValuteSocieta ON dbo.BUDGET_CALCULATE_PEG.BDD_KeyEnte = dbo.Budget_ValuteSocieta.BDS_CodSoc AND 
                      dbo.BUDGET_CALCULATE_PEG.BDD_BDG_Periodo = dbo.Budget_ValuteSocieta.BDS_BDG_Periodo INNER JOIN
                      dbo.Budget_Valute ON dbo.Budget_ValuteSocieta.BDS_CodiceValuta = dbo.Budget_Valute.BDV_CodiceValutaSource AND 
                      dbo.Budget_ValuteSocieta.BDS_BDG_Periodo = dbo.Budget_Valute.BDV_BDG_Periodo


GO
