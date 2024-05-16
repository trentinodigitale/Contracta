USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PARAMETRI_CONVENZIONE_DETTAGLI_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_PARAMETRI_CONVENZIONE_DETTAGLI_FROM_USER] as
select
	p.idpfu as ID_FROM,
	D.*
from 
ctl_doc
	inner join
		document_convenzione_parametri_soglie D on id=idheader and D.deleted=0
	cross join profiliUtente p
where  
	tipodoc='parametri_convenzione' 
	and statofunzionale='confermato'

GO
