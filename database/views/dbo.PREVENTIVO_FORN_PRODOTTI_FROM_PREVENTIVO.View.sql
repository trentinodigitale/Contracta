USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREVENTIVO_FORN_PRODOTTI_FROM_PREVENTIVO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[PREVENTIVO_FORN_PRODOTTI_FROM_PREVENTIVO]  as
SELECT  IdHeader as ID_FROM 
		,IdHeader
		,DSE_ID
		,Row
		,DZT_Name
		,Value
FROM   dbo.CTL_DOC_Value where DSE_ID = 'PRODOTTI' and dzt_name in
('RDP_CodArtProd'
,'RDP_Desc'
,'RDP_Qt'
,'RDP_UMNonCod'
,'RDP_Importo'
,'IVA'
,'QtMin'
,'QtMax'
,'TipoProdotto'
,'PercSconto'
,'CoefCorr'
,'CostoComplessivo'
,'DataUtilizzo'
,'ImportoCompenso'
,'RDP_Merceologia'
,'RDP_Fornitore'
,'Nota'
--,'NonEditabili'
,'Id_Product'
,'RDP_Allegato'
)
GO
