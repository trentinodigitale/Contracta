USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_SCRITTURA_PRIVATA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[MAIL_SCRITTURA_PRIVATA] as

select	
	 
	  CF.id as iddoc
	, lngSuffisso as LNG
	, convert( varchar , getdate() , 103 ) as DataOperazione
	, isnull( ML_Description , DOC_DescML ) as TipoDoc
	, CF.TipoDoc  as TipoDocumento
	, CF.Protocollo
	, isnull(CF.Body,'') as OggettoGara
	, CF.ProtocolloRiferimento as ProtocolloGara
	, a.aziRagioneSociale as aziragionesocialeforn
	, CF.StatoFunzionale
	, DB.Cig
	, dbo.Get_Cig_Contratto(CF.id) as ElencoCig
from 
	ctl_doc CF with (nolock)
	cross join Lingue with (nolock)
	left join aziende a with (nolock) on a.idazi = CF.Destinatario_Azi
	inner join LIB_Documents with (nolock) on DOC_ID = CF.TipoDoc
	left outer join LIB_Multilinguismo with (nolock) on DOC_DescML = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso
	inner join CTL_DOC B with (nolock) on B.Protocollo=CF.ProtocolloRiferimento and B.TipoDoc='BANDO_GARA' and B.Deleted=0
	inner join Document_Bando DB with (nolock) on DB.idHeader = B.id
	where 
		CF.TipoDoc='SCRITTURA_PRIVATA' and CF.Deleted=0 and CF.StatoFunzionale='Confermato'




GO
