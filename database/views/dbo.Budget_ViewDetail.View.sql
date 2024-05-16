USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Budget_ViewDetail]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Budget_ViewDetail] AS
SELECT     dbo.Budget_Detail.BDD_Importo * dbo.Budget_Valute.BDV_ValueDest AS BDD_Importo, dbo.Budget_Valute.BDV_CodiceValutaDest, 
                      dbo.Budget_Detail.BDD_BDG_Periodo, dbo.Budget_Detail.BDD_KeySOC, dbo.Budget_Detail.BDD_KeyPlant, dbo.Budget_Detail.BDD_KeyVDS, 
                      dbo.Budget_Detail.BDD_KeyCDC, dbo.Budget_Detail.BDD_KeyMerceologia, dbo.Budget_Detail.BDD_KeyProgetto, 
                      dbo.Budget_Detail.BDD_KeyFornitore, dbo.Budget_Detail.BDD_KeyCodArtProd, dbo.Budget_Detail.BDD_Commessa, dbo.Budget_Detail.BDD_Check, 
                      dbo.Budget_Detail.BDD_Level, dbo.Budget_Detail.BDD_id, dbo.Budget_Detail.BDD_KeySOCRic, dbo.Budget_Detail.BDD_KeyPlantRic, 
                      dbo.Budget_Detail.BDD_KeyTipoInvestimento 
--, case when BDD_Level = 3 then '1' else '0' end as BDG_ECONOMO
, case BDD_Level   when 3 then '1'
                   when 4 then '1' 
        else '0' end as BDG_ECONOMO
					, BDD_Note
FROM         dbo.Budget_Detail INNER JOIN
                      dbo.Budget_ValuteSocieta ON dbo.Budget_Detail.BDD_KeySOC = dbo.Budget_ValuteSocieta.BDS_CodSoc AND 
                      dbo.Budget_Detail.BDD_BDG_Periodo = dbo.Budget_ValuteSocieta.BDS_BDG_Periodo INNER JOIN
                      dbo.Budget_Valute ON dbo.Budget_ValuteSocieta.BDS_CodiceValuta = dbo.Budget_Valute.BDV_CodiceValutaSource AND 
                      dbo.Budget_ValuteSocieta.BDS_BDG_Periodo = dbo.Budget_Valute.BDV_BDG_Periodo


GO
