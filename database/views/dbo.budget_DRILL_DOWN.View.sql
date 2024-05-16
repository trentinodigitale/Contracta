USE [AFLink_TND]
GO
/****** Object:  View [dbo].[budget_DRILL_DOWN]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[budget_DRILL_DOWN]
AS
SELECT     CASE WHEN NOT bdm_numord IS NULL THEN bdm_numord WHEN BDM_TYPEMovement = 'Prenotation' AND bdm_numord IS NULL 
                      THEN 'RDA' ELSE '' END AS OPEN_DOC_NAME, CASE WHEN dbo.Budget_Movement.BDM_IdMsg IS NULL 
                      THEN bdm_id ELSE bdm_idmsg END AS bdm_id, 
				dbo.Budget_Movement.BDM_BDG_Periodo AS BDG_Periodo, 
				dbo.Budget_Movement.BDM_Data, 
				BDD_KeySOC, 
				BDD_KeyPlant, 
				BDD_KeyVDS, 
				BDD_KeyCDC, 
				BDD_KeyMerceologia, 
				BDD_KeyProgetto, 
				BDD_KeyFornitore, 
				BDD_KeyCodArtProd, 
				BDD_Commessa, 
				dbo.Budget_Movement.BDM_Importo AS BDD_Importo, 
				dbo.Budget_Movement.BDM_OriginalImporto, 
				dbo.Budget_Movement.BDM_OriginalValuta, 
				dbo.Budget_Movement.BDM_isOld, 
				dbo.Budget_Movement.BDM_Tiket, 
				dbo.Budget_Movement.BDM_TypeMovement, 
				BDD_KeyTipoInvestimento, 
				dbo.Budget_Movement.BDM_KeySOCRic AS BDD_KeySOCRic, 
				dbo.Budget_Movement.BDM_KeyPlantRic AS BDD_KeyPlantRic, 
				dbo.Budget_Movement.BDM_idPfu, dbo.Budget_Movement.BDM_IdMsg, 
				dbo.Budget_Movement.BDM_NumOrd, 
				dbo.Budget_Movement.BDM_Causale, 
				dbo.ProfiliUtente.pfuNome AS UserName
				, '1' as BDG_ECONOMO
FROM         dbo.Budget_Movement 
		inner join Budget_Detail on bdm_bdd_id = bdd_id
		LEFT OUTER JOIN
                      dbo.ProfiliUtente ON dbo.Budget_Movement.BDM_idPfu = dbo.ProfiliUtente.IdPfu
WHERE     (dbo.Budget_Movement.BDM_isOld = 0)
GO
