USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_FORNITORI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_FORNITORI] 
AS
select 
	Id,
	CTL_DOC.IdPfu,
	TipoDoc,
	StatoDoc,
	Fascicolo,
	Data,
	CTL_DOC.Protocollo,
	PrevDoc,
	Titolo,
	CTL_DOC.Deleted,
	convert(varchar(2000),Body) as Body,
	DataInvio,
	LinkedDoc,
	StatoFunzionale,
	CTL_DOC.idpfu as [owner],
	0 as bRead ,
	LinkedDoc as IdCom,
	Titolo as Name,
	DataInvio as DataCreazione,
	'COM_DPE_RISPOSTA' as OPEN_DOC_NAME,
	'2' AS StatoGD,
	'1' as OpenDettaglio,
	C.DataCreazione as DataCreazione1,
	C.Protocollo as ProtocolloRiferimento,
	b2.aziRagioneSociale as EnteAppaltante,
					b2.idazi as AZI_Ente

from  CTL_DOC with(nolock)
	inner join dbo.Document_Com_DPE C with(nolock) on IdCom=LinkedDoc
	 left outer join ProfiliUtente b1  with (nolock) on b1.idpfu = CTL_DOC.Destinatario_User  
	left outer join Aziende  b2 with (nolock) on b1.pfuIdAzi    = b2.idazi and b2.aziAcquirente = 3
where TipoDoc='COM_DPE_RISPOSTA'

union all

select 
	C.Id,
	C.IdPfu,
	C.TipoDoc,
	C.StatoDoc,
	C.Fascicolo,
	C.Data,
	C.Protocollo,
	C.PrevDoc,
	C.Titolo,
	C.Deleted,
	convert(varchar(2000),C.Body) as Body,
	C.DataInvio,
	C.LinkedDoc,
	C.StatoFunzionale,
	P.idpfu as [owner],
	0 as bRead ,
	C.LinkedDoc as IdCom,
	case when C.Tipodoc in ('VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN') then 'Modifica Dati Registrazione' else C.Titolo end as Name,
	C.DataInvio as DataCreazione,
	 C.TipoDoc as OPEN_DOC_NAME,
	'2' AS StatoGD,
	'1' as OpenDettaglio,
	C2.DataInvio as DataCreazione1,
	C2.Protocollo as ProtocolloRiferimento,
	b2.aziRagioneSociale as EnteAppaltante,
					b2.idazi as AZI_Ente

from  CTL_DOC C with(nolock)
		inner join CTL_DOC C2 with(nolock) on C.LinkedDoc=C2.ID
		inner join profiliutente P with(nolock) on p.pfuidazi=C.azienda
		left outer join ProfiliUtenteAttrib pa with(nolock) on pa.idpfu = p.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'

		 left outer join ProfiliUtente b1  with (nolock) on b1.idpfu = c.Destinatario_User  
		 left outer join Aziende  b2 with (nolock) on b1.pfuIdAzi    = b2.idazi and b2.aziAcquirente = 3

where C.TipoDoc in ('PDA_COMUNICAZIONE_RISP','PDA_COMUNICAZIONE_OFFERTA_RISP','VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN',
				'INTEGRA_ISCRIZIONE_RIS','INTEGRA_ISCRIZIONE_RIS_SDA')
		and ( C.idpfu = p.idpfu or C.idpfuincharge = p.idpfu or pa.idpfu is not null)


GO
