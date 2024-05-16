USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOCUMENT_PRODOTTI_DOSSIER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DOCUMENT_PRODOTTI_DOSSIER] AS
SELECT 
	 id as idHEader
	 ,id
	 ,'1' as CARValGenerico
     , v11.value as CARQuantitaDaOrdinare
     , v1.value AS [Codice Articolo]
     , v4.value as PrzUnOfferta
     , v2.value AS [descrizione articolo]

FROM         
	CTL_DOC p  with(nolock) 
	inner join profiliutente u  with(nolock) on p.idpfu = u.idpfu
	inner join ( select distinct Row , IdHeader from CTL_DOC_Value  with(nolock) where DSE_ID = 'PRODOTTI' ) as v on v.IdHeader = p.id 
	inner join CTL_DOC_Value v1 with(nolock)  on v1.IdHeader = p.id and v.Row = v1.Row and v1.DZT_Name = 'RDP_CodArtProd'
	inner join CTL_DOC_Value v2 with(nolock)  on v2.IdHeader = p.id and v.Row = v2.Row and v2.DZT_Name = 'RDP_Desc'
	inner join CTL_DOC_Value v4 with(nolock)  on v4.IdHeader = p.id and v.Row = v4.Row and v4.DZT_Name = 'RDP_Importo'
	inner join CTL_DOC_Value v11 with(nolock)  on v11.IdHeader = p.id and v.Row = v11.Row and v11.DZT_Name = 'RDP_Qt'




GO
