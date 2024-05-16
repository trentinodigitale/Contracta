USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_PREVENTIVO_FORN]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create view [dbo].[MAIL_PREVENTIVO_FORN] as
select
	d.id as iddoc
	,lngSuffisso as LNG
	, aziRagionesociale as RagioneSociale
	, isnull( ML_Description , DOC_DescML ) as TipoDoc
	, Body
	, Protocollo
	, convert( varchar , DataInvio , 103 ) as DataInvio
	, convert( varchar , DataInvio , 108 ) as OraInvio
from ctl_doc d
cross join Lingue
inner join profiliutente p on p.idpfu = d.idpfu
inner join aziende a on a.idazi = p.pfuidazi
inner join LIB_Documents on DOC_ID = TipoDoc
left outer join LIB_Multilinguismo on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso


GO
