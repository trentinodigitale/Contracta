USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_REVOCA_BANDO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_REVOCA_BANDO] as 
Select
	 d.id as iddoc
	,lngSuffisso as LNG
	, convert( varchar , CT.DataInvio , 103 ) as DataInvio
	, isnull( ML_Description , DOC_DescML ) as TipoDoc
	--, a.aziRagionesociale as RagioneSociale
	, CT.Body
	, d.Protocollo
	, ba.ProtocolloBando
	, CT.Titolo	 
	
	
	

from 
CTL_DOC d
cross join Lingue
inner join CTL_DOC CT on d.linkeddoc=CT.id
inner join LIB_Documents on DOC_ID = d.TipoDoc
inner join document_bando ba on CT.id = ba.idheader
left join profiliutente p on pfuidazi = d.idpfu
left outer join LIB_Multilinguismo on 'REVOCA_BANDO' = ML_KEY and ML_Context = 0 and ML_LNG = lngSuffisso

GO
