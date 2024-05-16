USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_BANDO] as
select 
	TipoDoc as OPEN_DOC_NAME,
	id,
	idpfu,
	iddoc,
	TipoDoc,
	StatoDoc,
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
	RecivedIstanze,
	ReceivedQuesiti
	,N_Cancellato
	,N_Sospeso
	,N_Iscritto
	,isnull(JumpCheck,'') as JumpCheck
from CTL_DOC  d with(nolock) 
	inner join dbo.Document_Bando  b with(nolock) on id = b.idheader
	left outer join ( select idheader , 
						sum( case when statoiscrizione = 'Cancellato' then 1 else 0 end ) as N_Cancellato , 
						sum( case when statoiscrizione = 'Sospeso' and A.aziDeleted = 0 then 1 else 0 end ) as N_Sospeso ,
						sum( case when statoiscrizione = 'Iscritto' and A.aziDeleted = 0  then 1 else 0 end ) as N_Iscritto 
						from ctl_doc_destinatari  D
						  
						  inner join Aziende A on D.idazi=A.idazi --and A.aziDeleted =0
						
						group by idheader 
					) as c on c.idHeader = d.id


where deleted = 0 and TipoDoc in ( 'BANDO' )










GO
