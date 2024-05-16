USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Cambio_Rappresentante_Legale_INAPPROVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_Cambio_Rappresentante_Legale_INAPPROVE]  as
select
	Id, 
	d.IdPfu, 
	IdDoc, 
	TipoDoc, 
	StatoDoc, 
	DataInvio, 
	Protocollo, 
	PrevDoc, 
	Deleted, 
	Titolo, 
	Body, 
	Azienda, 
	StatoFunzionale ,
	aziRagioneSociale,
	aziAcquirente,
	AziVenditore,
	v1.Value as Utente
from CTL_DOC d
	inner join profiliutente p on p.idpfu =  d.idpfu
	inner join aziende on idazi = pfuidazi
	left outer join CTL_DOC_VALUE v1 on v1.idheader =d.id and v1.DZT_Name = 'Utente'
where tipodoc='CAMBIO_RAPLEG'
and StatoFunzionale in ( 'InValutazione','Confermato')
and deleted=0
GO
