USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_BANDO_ALBO_IN_APPROVE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_DASHBOARD_VIEW_BANDO_ALBO_IN_APPROVE] as
select 
	'BANDO_ALBO_IN_APPROVE' as OPEN_DOC_NAME,
	id,
	d.idpfu,
	iddoc,
	DC.idpfu as InCharge,
	TipoDoc,
	StatoDoc,
	TipoBando,
	Data,
	Protocollo,
	PrevDoc,
	Deleted,
	case when isnull(Titolo,'') = '' then cast( Body as nvarchar(4000) ) 
		else Titolo
	end as Titolo,
	Body,
	Azienda,
	StrutturaAziendale,
	DataInvio,
	DataScadenza,
	ProtocolloGenerale,
	Fascicolo,
	Note,
	DataProtocolloGenerale,
	LinkedDoc,
	StatoFunzionale,
	Destinatario_User,
	Destinatario_Azi ,
	RecivedIstanze

from CTL_DOC  d  with(nolock) 
	inner join dbo.Document_Bando DB  with(nolock) on id = DB.idheader
	inner join Document_Bando_Commissione DC  with(nolock) on DC.idHEader=id and RuoloCommissione=15550
where deleted = 0 and TipoDoc in ( 'BANDO' )









GO
