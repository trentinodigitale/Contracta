USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BUDGET_DETAIL_X_KEY]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[BUDGET_DETAIL_X_KEY]
AS
SELECT     BDD_BDG_Periodo, BDD_DataCreazione, BDD_KeySOC, BDD_KeyPlant, BDD_KeyVDS, BDD_KeyCDC, BDD_KeyMerceologia, BDD_KeyProgetto, 
                      BDD_KeyFornitore, BDD_KeyCodArtProd, BDD_KeySOCRic, BDD_KeyPlantRic, BDD_Commessa, BDD_Importo, BDD_Check, BDD_Level, BDD_id, 
                      BDD_KeyTipoInvestimento, 
                      BDD_KeySOC + '-#-' + BDD_KeyPlant + '-#-' + BDD_KeyVDS + '-#-' + BDD_KeyCDC + '-#-' + BDD_KeyMerceologia + '-#-' + BDD_KeyProgetto + '-#-' + BDD_KeyFornitore
                       + '-#-' + BDD_KeyCodArtProd + '-#-' + BDD_KeyTipoInvestimento + '-#-' + BDD_KeySOCRic + '-#-' + BDD_KeyPlantRic + '-#-' + BDD_BDG_Periodo AS BKEY
FROM         dbo.Budget_Detail



GO
