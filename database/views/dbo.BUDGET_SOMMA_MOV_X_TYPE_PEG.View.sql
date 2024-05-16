USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BUDGET_SOMMA_MOV_X_TYPE_PEG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from viste where view_definition like '%budget_movement%'

CREATE VIEW [dbo].[BUDGET_SOMMA_MOV_X_TYPE_PEG]
AS
SELECT     SUM(BDM_Importo) AS Somma, BDM_TypeMovement AS TypeMovement, BDM_BDD_id
FROM         dbo.Budget_Movement_PEG
WHERE     (BDM_isOld = 0)
GROUP BY BDM_BDD_id, BDM_TypeMovement


GO
