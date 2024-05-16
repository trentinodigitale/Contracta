USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ODC_PRODOTTI_FROM_PREVENTIVO_FORN]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
---------------------------------------------------------------
--aggiunti i campi IVA e TipoProdotto
---------------------------------------------------------------

CREATE VIEW [dbo].[ODC_PRODOTTI_FROM_PREVENTIVO_FORN] as
SELECT p.Id as ID_FROM
     , '' as Marca
     , v1.value AS RDP_CodArtProd
     , v2.value AS RDP_Desc
     , v3.value as QtMin
     , v4.value as RDP_Importo
     , v10.value as RDP_Fornitore 
     --, NumConf                    AS RDP_Qt
     , v11.value as RDP_Qt
     , v5.value as Nota
	 , ' RDP_Qt RDP_Importo RDP_Desc ' as NonEditabili
     , v6.value as PercSconto
	 , 1 as CoefCorr
	 , v7.value as Id_Product
	 , v8.value as ImportoCompenso
	 , v12.value as RDP_Allegato

	 , v13.value as IVA
	 , v14.value as TipoProdotto

	
--  FROM Carrello
FROM         
	CTL_DOC p 
	inner join profiliutente u on p.idpfu = u.idpfu
	inner join ( select distinct Row , IdHeader from CTL_DOC_Value where DSE_ID = 'PRODOTTI' ) as v on v.IdHeader = p.id 
	inner join CTL_DOC_Value v1 on v1.IdHeader = p.id and v.Row = v1.Row and v1.DZT_Name = 'RDP_CodArtProd'
	inner join CTL_DOC_Value v2 on v2.IdHeader = p.id and v.Row = v2.Row and v2.DZT_Name = 'RDP_Desc'
	inner join CTL_DOC_Value v3 on v3.IdHeader = p.id and v.Row = v3.Row and v3.DZT_Name = 'QtMin'
	inner join CTL_DOC_Value v4 on v4.IdHeader = p.id and v.Row = v4.Row and v4.DZT_Name = 'RDP_Importo'
	inner join CTL_DOC_Value v5 on v5.IdHeader = p.id and v.Row = v5.Row and v5.DZT_Name = 'Nota'
	inner join CTL_DOC_Value v6 on v6.IdHeader = p.id and v.Row = v6.Row and v6.DZT_Name = 'PercSconto'
	inner join CTL_DOC_Value v7 on v7.IdHeader = p.id and v.Row = v7.Row and v7.DZT_Name = 'Id_Product'
	inner join CTL_DOC_Value v8 on v8.IdHeader = p.id and v.Row = v8.Row and v8.DZT_Name = 'ImportoCompenso'
	inner join CTL_DOC_Value v10 on v10.IdHeader = p.id and v.Row = v10.Row and v10.DZT_Name = 'RDP_Fornitore'
	inner join CTL_DOC_Value v11 on v11.IdHeader = p.id and v.Row = v11.Row and v11.DZT_Name = 'RDP_Qt'
	inner join CTL_DOC_Value v12 on v12.IdHeader = p.id and v.Row = v12.Row and v12.DZT_Name = 'RDP_Allegato'

	inner join CTL_DOC_Value v13 on v13.IdHeader = p.id and v.Row = v13.Row and v13.DZT_Name = 'IVA'
	inner join CTL_DOC_Value v14 on v14.IdHeader = p.id and v.Row = v14.Row and v14.DZT_Name = 'TipoProdotto'
GO
