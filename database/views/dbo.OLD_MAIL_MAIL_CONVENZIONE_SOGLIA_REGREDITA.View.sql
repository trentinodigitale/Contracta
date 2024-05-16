USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_MAIL_CONVENZIONE_SOGLIA_REGREDITA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_MAIL_MAIL_CONVENZIONE_SOGLIA_REGREDITA] as

select 
	CL.idrow as iddoc
	,lngSuffisso as LNG
	,C.Protocollo,C.Titolo--,C.Body,
	,CL.NumeroLotto
	,min(PS.soglia) as SogliaSuperata
	,DC.NumOrd as NumeroConvenzioneCompleta
from
	ctl_doc C with(nolock)
		inner join Document_Convenzione DC with(nolock) on DC.ID=C.id
		inner join document_convenzione_lotti CL with(nolock) on CL.idheader=C.id
		inner join profiliutente p with(nolock) on p.idpfu = C.idpfu
		inner join lingue  with(nolock) on pfuidlng=idlng
		left outer join document_convenzione_parametri_soglie PS with(nolock) on PS.deleted=0 and Ps.soglia > CL.sogliasuperata
group by CL.idrow,lngSuffisso,Protocollo,Titolo,CL.NumeroLotto,DC.NumOrd
GO
