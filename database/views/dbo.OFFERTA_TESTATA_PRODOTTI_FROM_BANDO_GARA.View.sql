USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_TESTATA_PRODOTTI_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OFFERTA_TESTATA_PRODOTTI_FROM_BANDO_GARA] as
SELECT 

	v.idheader  as ID_FROM 
	, v.Value	 as AllegatoRichiesto
	, v.DZT_Name
	, v.Value
	, ClausolaFideiussoria
	,Help_Offerte
	FROM CTL_DOC_Value v 
		inner join document_Bando b on  b.idheader = v.idheader
		left outer join Document_Modelli_MicroLotti m on m.deleted = 0 and  m.Codice = b.tipoBando
	where v.DZT_Name = 'Allegato' and v.DSE_ID = 'TESTATA_PRODOTTI'



GO
