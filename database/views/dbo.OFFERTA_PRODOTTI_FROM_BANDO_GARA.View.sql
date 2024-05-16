USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_PRODOTTI_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  view [dbo].[OFFERTA_PRODOTTI_FROM_BANDO_GARA] as
SELECT 

	id as ID_FROM   
	, v.Value	 as AllegatoRichiesto
	, v.DZT_Name
	, v.Value
	FROM         CTL_DOC  d
			inner join CTL_DOC_Value v on d.id = v.idheader and DZT_Name = 'Allegato' and DSE_ID = 'TESTATA_PRODOTTI'



GO
