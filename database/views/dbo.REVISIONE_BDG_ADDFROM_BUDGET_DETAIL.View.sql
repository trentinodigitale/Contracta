USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REVISIONE_BDG_ADDFROM_BUDGET_DETAIL]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*----------------------------------------*/
CREATE VIEW [dbo].[REVISIONE_BDG_ADDFROM_BUDGET_DETAIL]
AS
SELECT     BDD_id AS indRow, BDD_KeyPlant, BDD_KeyVDS, BDD_KeyCDC, BDD_KeyProgetto, BDD_KeyFornitore, BDD_KeyCodArtProd, BDD_KeySOCRic, 
                      BDD_KeyPlantRic, BDD_KeyTipoInvestimento, BDD_KeyMerceologia, BDD_Commessa, BDG_TOT_Consuntivo AS ConsuntivoBudget, 
                      BDG_TOT_Definizione AS PrevisionaleBudget, BDG_TOT_Definizione AS NewPrevisionalex, BDG_TOT_Residuo AS NewPrevisionale
FROM         dbo.BUDGET_CALCULATE


GO
