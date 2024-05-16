USE [AFLink_TND]
GO
/****** Object:  View [dbo].[budget_DRILL_DOWN_PEG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[budget_DRILL_DOWN_PEG]
AS
SELECT     

 isnull(bdm_DOCUMENT,'') AS OPEN_DOC_NAME, 
    	   CASE 
				WHEN dbo.Budget_Movement_PEG.BDM_IdMsg IS NULL THEN min(bdm_id) 
				ELSE bdm_idmsg 
			END AS bdm_id,
			dbo.Budget_Movement_PEG.BDM_BDG_Periodo AS BDG_Periodo, 
			dbo.Budget_Movement_PEG.BDM_Data, 
            dbo.Budget_Movement_PEG.BDM_KeyEnte AS BDD_Keyente, dbo.Budget_Movement_PEG.BDM_Keyarea AS BDD_Keyarea, 
            dbo.Budget_Movement_PEG.BDM_KeyCDR AS BDD_KeyCDR, dbo.Budget_Movement_PEG.BDM_KeyPegCDC AS BDD_KeyPegCDC, 
            dbo.Budget_Movement_PEG.BDM_KeyCapitolo AS BDD_KeyCapitolo, dbo.Budget_Movement_PEG.BDM_KeyProgetto AS BDD_KeyProgetto, 
            sum(dbo.Budget_Movement_PEG.BDM_Importo) AS BDD_Importo, 
            sum(dbo.Budget_Movement_PEG.BDM_OriginalImporto) as BDM_OriginalImporto , 
			dbo.Budget_Movement_PEG.BDM_OriginalValuta, dbo.Budget_Movement_PEG.BDM_isOld, 
            dbo.Budget_Movement_PEG.BDM_Tiket, dbo.Budget_Movement_PEG.BDM_TypeMovement, 
            dbo.Budget_Movement_PEG.BDM_KeyCodIntervento AS BDD_KeyCodIntervento, 
            dbo.Budget_Movement_PEG.BDM_idPfu, dbo.Budget_Movement_PEG.BDM_Fornitore as Fornitore, 
            dbo.ProfiliUtente.pfuNome AS UserName

FROM         dbo.Budget_Movement_PEG LEFT OUTER JOIN
                      dbo.ProfiliUtente ON dbo.Budget_Movement_PEG.BDM_idPfu = dbo.ProfiliUtente.IdPfu
WHERE     (dbo.Budget_Movement_PEG.BDM_isOld = 0)
group by bdm_DOCUMENT,bdm_idmsg,BDM_BDG_Periodo,BDM_Data,BDM_KeyEnte,
		BDM_Keyarea,BDM_KeyCDR,BDM_KeyPegCDC,BDM_KeyCapitolo,BDM_KeyProgetto,
	    BDM_OriginalValuta,BDM_isOld,BDM_Tiket,BDM_TypeMovement,
		BDM_KeyCodIntervento,BDM_idPfu,dbo.Budget_Movement_PEG.BDM_Fornitore,pfuNome

GO
