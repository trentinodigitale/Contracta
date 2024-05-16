USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RISPOSTA_CONSULTAZIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_RISPOSTA_CONSULTAZIONE] AS

select 
	 d.id as iddoc
	,lngSuffisso as LNG
	, a.aziRagionesociale as RagioneSociale
	, isnull( ML_Description , DOC_DescML ) as TipoDoc
	,d.Protocollo
	, A3.aziRagionesociale as fornitoreistanza
	, bando.Protocollo as ProtocolloBando
	, ISNULL(d.Body,d.note) as body
	, convert( varchar , d.DataInvio , 103 ) as DataInvio
	, convert( varchar , d.DataInvio , 108 ) as OraInvio
from ctl_doc d with(NOLOCK)
	cross join Lingue with(NOLOCK)
	left join profiliutente p with(NOLOCK) on p.idpfu = d.idpfu
	left join aziende a with(NOLOCK) on a.idazi = p.pfuidazi
	inner join LIB_Documents with(NOLOCK) on DOC_ID = TipoDoc
	left outer join LIB_Multilinguismo with(NOLOCK) on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
	left join aziende A3 with(NOLOCK) on d.Destinatario_azi=A3.idazi
	left join ctl_doc bando with(NOLOCK) on bando.id=d.LinkedDoc
where d.TipoDoc='RISPOSTA_CONSULTAZIONE'

GO
