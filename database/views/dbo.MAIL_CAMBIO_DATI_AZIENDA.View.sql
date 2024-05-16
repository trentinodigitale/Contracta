USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CAMBIO_DATI_AZIENDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MAIL_CAMBIO_DATI_AZIENDA] as
select 
	c.id as IdDoc
	, a.aziRagioneSociale as Fornitore
	, i.Protocollo
	, b.Protocollo  as ProtocolloBando
	, convert( varchar(20) , i.DataInvio , 103 ) as DataInvio
	, isnull( ML_Description , DOC_DescML ) as DocType
	, lngSuffisso as LNG

from CTL_DOC c --Conferma iscrizione
	inner join aziende a on c.Destinatario_AZI = a.idazi -- fornitore
	inner join CTL_DOC i on c.LinkedDoc = i.id -- Istanza
	inner join CTL_DOC b on i.LinkedDoc = b.id -- Bando
	inner join LIB_Documents on DOC_ID = i.tipoDoc
	CROSS join Lingue l
	inner join LIB_Multilinguismo on ML_KEY = DOC_DescML and ML_LNG = lngSuffisso
GO
