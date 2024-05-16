USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CONTRATTO_CONVENZIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MAIL_CONTRATTO_CONVENZIONE] as
select	
	 
	  d.id as iddoc
	, lngSuffisso as LNG
	, convert( varchar , getdate() , 103 ) as DataOperazione
	, isnull( ML_Description , DOC_DescML ) as TipoDoc
	, d.TipoDoc  as TipoDocumento
	, d.Protocollo
	, d2.titolo as NomeConvenzione
	, d2.Protocollo as ProtocolloConvenzione
	, a.aziRagioneSociale as aziragionesocialeforn

from ctl_doc d
	cross join Lingue
	--left join profiliutente p on p.idpfu = d.idpfu
	left join aziende a on a.idazi = d.Destinatario_Azi
	inner join LIB_Documents on DOC_ID = TipoDoc
	left outer join LIB_Multilinguismo on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
	inner join ctl_doc d2 on d.linkeddoc=d2.id and d2.tipodoc='CONVENZIONE'
GO
