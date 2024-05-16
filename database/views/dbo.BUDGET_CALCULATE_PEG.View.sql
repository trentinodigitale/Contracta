USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BUDGET_CALCULATE_PEG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE VIEW [dbo].[BUDGET_CALCULATE_PEG]
AS
SELECT     m2.Somma AS BDG_TOT_inProcess, ISNULL(m3.Somma, 0) AS BDG_TOT_Buyer, ISNULL(m4.Somma, 0) AS BDG_TOT_Ordered, ISNULL(m1.Somma, 
                      0) + ISNULL(m2.Somma, 0) + ISNULL(m3.Somma, 0) + ISNULL(m4.Somma, 0) + ISNULL(m5.Somma, 0) + ISNULL(m6.Somma, 0) AS BDG_TOT_Residuo, 
                      - (ISNULL(m2.Somma, 0) + ISNULL(m3.Somma, 0) + ISNULL(m4.Somma, 0)) AS BDG_TOT_Consuntivo, ISNULL(m1.Somma, 0) + ISNULL(m5.Somma, 0) 
                      + ISNULL(m6.Somma, 0) AS BDG_TOT_Definizione, a.BDD_BDG_Periodo, a.BDD_DataCreazione, a.BDD_KeyEnte, a.BDD_KeyArea, a.BDD_KeyCDR, 

                      a.BDD_KeyPEGCDC, a.BDD_KeyUAC, a.BDD_KeyProgetto, a.BDD_KeyCApitolo,a.BDD_KeyCodIntervento ,
                       a.BDD_Importo, a.BDD_Check, a.BDD_Level, a.BDD_id
FROM         dbo.BUDGET_DETAIL_PEG AS a LEFT OUTER JOIN
                      dbo.BUDGET_SOMMA_MOV_X_TYPE_PEG AS m1 ON a.bdd_id = m1.bdm_bdd_id AND m1.TypeMovement = 'BudgetDefinition' LEFT OUTER JOIN
                      dbo.BUDGET_SOMMA_MOV_X_TYPE_PEG AS m2 ON a.bdd_id = m2.bdm_bdd_id AND m2.TypeMovement = 'Prenotation' LEFT OUTER JOIN
                      dbo.BUDGET_SOMMA_MOV_X_TYPE_PEG AS m3 ON a.bdd_id = m3.bdm_bdd_id AND m3.TypeMovement = 'Approvation' LEFT OUTER JOIN
                      dbo.BUDGET_SOMMA_MOV_X_TYPE_PEG AS m4 ON a.bdd_id = m4.bdm_bdd_id AND m4.TypeMovement = 'Ordered' LEFT OUTER JOIN
                      dbo.BUDGET_SOMMA_MOV_X_TYPE_PEG AS m5 ON a.bdd_id = m5.bdm_bdd_id AND m5.TypeMovement = 'Rettifica' LEFT OUTER JOIN
                      dbo.BUDGET_SOMMA_MOV_X_TYPE_PEG AS m6 ON a.bdd_id = m6.bdm_bdd_id AND m6.TypeMovement = 'Revisione' LEFT OUTER JOIN
                      dbo.BUDGET_SOMMA_MOV_X_TYPE_PEG AS m7 ON a.bdd_id = m7.bdm_bdd_id AND m7.TypeMovement = 'OrderDeleted'



GO
