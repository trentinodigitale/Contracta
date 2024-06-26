USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PRODUCT_ws_GETNEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PRODUCT_ws_GETNEW]
AS
select idart,
		artCode as CODICEPRODOTTO,
		dsctesto as DESCRIZIONEPRODOTTO,
		artIdUms as UMPRODOTTO,
		isnull(a1.vatvalore_ft,'') as CODICECLM,		
		isnull(a2.vatvalore_ft,'') as FATTCONVPRODOTTO,
		isnull(a3.vatvalore_ft,'') as ALQIVA,
		isnull(a4.vatvalore_ft,'') as FLGCHIUSURAPRODOTTO,
		isnull(a5.vatvalore_ft,'') as CODMINPRODOTTO,		
		isnull(a6.vatvalore_ft,'') as DTCREAZIONEPRODOTTO		
from articoli
inner join descsi on iddsc=artIdDscDescrizione
left outer join dm_attributi a1 on a1.idapp=2 and a1.lnk=idart and a1.dztnome='CODICECLM'
left outer join dm_attributi a2 on a2.idapp=2 and a2.lnk=idart and a2.dztnome='FATTCONVPRODOTTO'
left outer join dm_attributi a3 on a3.idapp=2 and a3.lnk=idart and a3.dztnome='ALQIVA'
left outer join dm_attributi a4 on a4.idapp=2 and a4.lnk=idart and a4.dztnome='FLGCHIUSURAPRODOTTO'
left outer join dm_attributi a5 on a5.idapp=2 and a5.lnk=idart and a5.dztnome='CODMINPRODOTTO'
left outer join dm_attributi a6 on a6.idapp=2 and a6.lnk=idart and a6.dztnome='DTCREAZIONEPRODOTTO'

GO
