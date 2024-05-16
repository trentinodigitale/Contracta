USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Budget_ViewDetail_PEG]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-------------------------------------




CREATE VIEW [dbo].[Budget_ViewDetail_PEG]
AS
SELECT      dbo.Budget_Detail_Peg.BDD_Importo * dbo.Budget_Valute.BDV_ValueDest AS BDD_Importo, 
			dbo.Budget_Valute.BDV_CodiceValutaDest, 
            dbo.Budget_Detail_Peg.BDD_BDG_Periodo, 
			dbo.Budget_Detail_Peg.BDD_KeyEnte, 
			dbo.Budget_Detail_Peg.BDD_KeyArea, 
			dbo.Budget_Detail_Peg.BDD_KeyCDR, 
			dbo.Budget_Detail_Peg.BDD_KeyUAC, 
			dbo.Budget_Detail_Peg.BDD_KeyPegCDC, 
			dbo.Budget_Detail_Peg.BDD_KeyCodintervento, 
			dbo.Budget_Detail_Peg.BDD_Keycapitolo, 
       		dbo.Budget_Detail_Peg.BDD_KeyProgetto, 
                      dbo.Budget_Detail_Peg.BDD_Check, 
                      dbo.Budget_Detail_Peg.BDD_Level, dbo.Budget_Detail_Peg.BDD_id
			from dbo.Budget_Detail_Peg INNER JOIN
                      dbo.Budget_ValuteSocieta ON dbo.Budget_Detail_Peg.BDD_KeyEnte = dbo.Budget_ValuteSocieta.BDS_CodSoc AND 
                      dbo.Budget_Detail_Peg.BDD_BDG_Periodo = dbo.Budget_ValuteSocieta.BDS_BDG_Periodo INNER JOIN
                      dbo.Budget_Valute ON dbo.Budget_ValuteSocieta.BDS_CodiceValuta = dbo.Budget_Valute.BDV_CodiceValutaSource AND 
                      dbo.Budget_ValuteSocieta.BDS_BDG_Periodo = dbo.Budget_Valute.BDV_BDG_Periodo





GO
