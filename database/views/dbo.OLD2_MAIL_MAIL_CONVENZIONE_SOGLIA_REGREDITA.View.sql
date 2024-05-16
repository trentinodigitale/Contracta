USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_MAIL_CONVENZIONE_SOGLIA_REGREDITA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[OLD2_MAIL_MAIL_CONVENZIONE_SOGLIA_REGREDITA] as

select 
	CL.idrow as iddoc
	,lngSuffisso as LNG
	,C.Protocollo,C.Titolo--,C.Body,
	,CL.NumeroLotto
	,min(PS.soglia) as SogliaSuperata
from
	ctl_doc C 
		inner join document_convenzione_lotti	CL on CL.idheader=C.id
		inner join profiliutente p on p.idpfu = C.idpfu
		inner join lingue  on pfuidlng=idlng
		left outer join 
			document_convenzione_parametri_soglie PS on PS.deleted=0 and Ps.soglia > CL.sogliasuperata
group by CL.idrow,lngSuffisso,Protocollo,Titolo,CL.NumeroLotto
			
			
GO
