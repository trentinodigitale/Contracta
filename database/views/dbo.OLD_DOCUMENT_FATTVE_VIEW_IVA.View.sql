USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOCUMENT_FATTVE_VIEW_IVA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_DOCUMENT_FATTVE_VIEW_IVA]
AS
	SELECT  idHeader, 
			v.DMV_CodExt as CodiceIVA, 
			v.dmv_father as Aliquota,
			LTRIM(STR( SUM(OrderLine_TotalTaxAmount), 10, 2 )) as TotaleTasse, 
			LTRIM(STR( SUM(OrderLine_LineExtensionAmount), 10, 2 )) as TotaleImporto
		FROM Document_NoTIER_Prodotti p with(nolock)
				inner join LIB_DomainValues v with(nolock) on v.DMV_DM_ID = 'UNCL5305' and v.DMV_Cod = p.OrderLine_ClassifiedTaxCategory_ID 
		where TipoDoc_collegato = 'FATTURA_PA'
		group by idHeader,OrderLine_ClassifiedTaxCategory_ID,DMV_CodExt,dmv_father
GO
