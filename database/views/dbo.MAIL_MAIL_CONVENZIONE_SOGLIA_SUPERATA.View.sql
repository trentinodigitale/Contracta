USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_MAIL_CONVENZIONE_SOGLIA_SUPERATA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_MAIL_CONVENZIONE_SOGLIA_SUPERATA] as

select 
	CL.idrow as iddoc
	,lngSuffisso as LNG
	,C.Protocollo,C.Titolo,CL.*, isnull(c.body,dc.DescrizioneEstesa) as Body
	,DC.NumOrd as NumeroConvenzioneCompleta
from
	ctl_doc C 
		inner join document_convenzione_lotti CL with (nolock) on CL.idheader=C.id
		inner join Document_Convenzione dc with (nolock) on dc.ID=CL.idheader
		inner join profiliutente p with (nolock) on p.idpfu = C.idpfu
		inner join lingue with (nolock)  on pfuidlng=idlng

GO
