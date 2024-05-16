USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_BANDO_RETTIFICATO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_MAIL_BANDO_RETTIFICATO] as
select 
     CM.id as iddoc
	,lngSuffisso as LNG
	, CT.Body
	, CT.Protocollo as ProtocolloBando

from 
CTL_Mail CM
inner join CTL_DOC_DESTINATARI d on d.idHeader=CM.iddoc
cross join Lingue
inner join CTL_DOC CT on d.idHeader=CT.id
inner join document_bando ba on CT.id = ba.idheader
where ct.tipodoc in ('BANDO','BANDO_SDA')
GO
