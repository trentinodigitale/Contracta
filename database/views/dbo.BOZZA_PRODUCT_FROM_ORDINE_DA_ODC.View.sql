USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BOZZA_PRODUCT_FROM_ORDINE_DA_ODC]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[BOZZA_PRODUCT_FROM_ORDINE_DA_ODC] as 
select
	  IDHeader AS ID_FROM
	, KeyRiga
	, CodArt
	, Merc
	, CARDescrNonCod
	, CARQuantitaDaOrdinare

from document_ordine_product




GO
