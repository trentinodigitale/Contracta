USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_SDA_FARMACI_TESTATA_PRODOTTI_FROM_BANDO_SDA_ADERENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[ISTANZA_SDA_FARMACI_TESTATA_PRODOTTI_FROM_BANDO_SDA_ADERENTE] as 

SELECT 

	b.IdRow as ID_FROM 
	, v.Value	 as AllegatoRichiesto
	, v.DZT_Name
	, v.Value
	FROM         
		CTL_DOC  d
		inner join CTL_DOC_Value v on d.id = v.idheader and v.DZT_Name = 'Allegato' and v.DSE_ID = 'TESTATA_PRODOTTI'
		inner join CTL_DOC_Value b on b.IdHeader = d.id and b.DSE_ID = 'ENTI' and b.DZT_Name = 'AZI_Ente' 
		
GO
