USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_BANDO_PROROGATO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_BANDO_PROROGATO] as
select 
     CM.id as iddoc
	,lngSuffisso as LNG
	, CT.Body
	, CT.Protocollo as ProtocolloBando

from 
CTL_Mail CM with (nolock)
inner join CTL_DOC d with (nolock) on d.id=CM.iddoc and CM.TypeDoc=d.TipoDoc
cross join Lingue with (nolock)
inner join CTL_DOC CT with (nolock) on d.LinkedDoc=CT.id
inner join document_bando ba with (nolock) on CT.id = ba.idheader
where ct.tipodoc in ('BANDO','BANDO_SDA')
GO
