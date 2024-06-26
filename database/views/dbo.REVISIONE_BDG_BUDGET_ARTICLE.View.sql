USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REVISIONE_BDG_BUDGET_ARTICLE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[REVISIONE_BDG_BUDGET_ARTICLE]
AS
SELECT     BDD_KeyFornitore AS RDP_Fornitore_Filter, BDD_BDG_Periodo AS BDG_Periodo, BDD_BDG_Periodo, BDD_DataCreazione, BDD_KeySOC, 
                      BDD_KeyPlant, BDD_KeyVDS, BDD_KeyCDC, BDD_KeyMerceologia, BDD_KeyProgetto, BDD_KeyFornitore, BDD_KeyCodArtProd, BDD_KeySOCRic, 
                      BDD_KeyPlantRic, BDD_Commessa, BDD_Importo, BDD_Check, BDD_Level, BDD_id, BDD_KeyTipoInvestimento
FROM         dbo.Budget_Detail
WHERE     (BDD_BDG_Periodo = CONVERT([varchar], DATEPART(year, GETDATE()), 0) + '0101')



------------------------------------------







GO
