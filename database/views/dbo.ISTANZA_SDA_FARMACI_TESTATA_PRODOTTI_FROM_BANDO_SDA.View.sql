USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_SDA_FARMACI_TESTATA_PRODOTTI_FROM_BANDO_SDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[ISTANZA_SDA_FARMACI_TESTATA_PRODOTTI_FROM_BANDO_SDA] as 

SELECT 

	id as ID_FROM   
	, v.Value	 as AllegatoRichiesto
	, v.DZT_Name
	, v.Value
	FROM         CTL_DOC  d
			inner join CTL_DOC_Value v on d.id = v.idheader and DZT_Name = 'Allegato' and DSE_ID = 'TESTATA_PRODOTTI'
		
GO
