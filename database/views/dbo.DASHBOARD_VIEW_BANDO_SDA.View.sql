USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDO_SDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_BANDO_SDA] as
select 
	TipoDoc as OPEN_DOC_NAME,
	id,
	d.idpfu,
	iddoc,
	TipoDoc,
	StatoDoc,
	TipoBando,
	Data,
	Protocollo,
	PrevDoc,
	Deleted,
	Titolo,
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
	RecivedIstanze , 
	ProtocolloBando

	,N_Cancellato
	,N_Sospeso
	,N_Iscritto
	,CV.value as TipoBandoScelta
	, P1.idpfu as Owner

from CTL_DOC  d  with(nolock) 
	inner join dbo.Document_Bando  with(nolock) on id = idheader
	
	inner join profiliutente P1 with (nolock) on P1.pfuIdAzi = d.azienda

	left outer join ( select idheader , 
						sum( case when statoiscrizione = 'Cancellato' then 1 else 0 end ) as N_Cancellato , 
						sum( case when statoiscrizione = 'Sospeso' and A.aziDeleted = 0  then 1 else 0 end ) as N_Sospeso ,
						sum( case when statoiscrizione = 'Iscritto' and A.aziDeleted = 0  then 1 else 0 end ) as N_Iscritto 
						from ctl_doc_destinatari D
						  inner join Aziende A on D.idazi=A.idazi --and A.aziDeleted =0
						  group by idheader 
						  
					) as c on c.idHeader = d.id
	--recupero il Modello Base Appalto Specifico
	left outer join CTL_DOC_Value CV on CV.idHeader=d.id and CV.DSE_ID='TESTATA_PRODOTTI' and CV.DZT_Name='TipoBandoScelta' 

where deleted = 0 and TipoDoc in ( 'BANDO_SDA' )





GO
