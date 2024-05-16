USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_HD_MESSAGE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_HD_MESSAGE] as
Select 
		C.ID as IdHeader,
		C.Id as IDDOC,
		convert( varchar , C.Data , 103 ) as Data,
		C1.Value as ticket,
		C.Titolo,
		C.StatoFunzionale as TipoDocumento,
		C.Body as Testo,
		'I' as LNG
from CTL_DOC C
inner join CTL_DOC C0 on C.LinkedDoc=C0.id
left join CTL_DOC_VALUE C1 on C1.idHeader=C0.id and C1.DSE_ID='TESTATA_SEGNALAZIONE' and C1.DZT_NAME='ticketAFS'
where C.TipoDoc='HD_MESSAGE' and C.deleted=0
GO
