USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_DOCUMENT_SIMPLE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MAIL_DOCUMENT_SIMPLE] as

	select	d.id as iddoc
			, lngSuffisso as LNG
			, d.tipodoc
			, d.data
			, d.Protocollo
			, d.titolo
			, d.Body
			, d.DataInvio
			, d.ProtocolloGenerale
 
	from ctl_doc d with(nolock) 
			cross join Lingue with(nolock) 
			left join profiliutente p  with(nolock) on p.idpfu = d.idpfu
			left join aziende a  with(nolock) on a.idazi = p.pfuidazi
GO
