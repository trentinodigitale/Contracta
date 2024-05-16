USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_FORNITORI_PER_ENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_FORNITORI_PER_ENTE] 
AS
select 
	Id,
	IdPfu,
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
	CTL_DOC.LinkedDoc,
	StatoFunzionale,
	
	0 as bRead ,
	CTL_DOC.LinkedDoc as IdCom,
	Titolo as Name,
	DataInvio as DataCreazione,
	'COM_DPE_RISPOSTA' as OPEN_DOC_NAME,
	'2' AS StatoGD,
	'1' as OpenDettaglio,
	C.DataCreazione as DataCreazione1,
	C.Protocollo as ProtocolloRiferimento
	

from  CTL_DOC with(nolock)
	inner join dbo.Document_Com_DPE C with(nolock) on IdCom=LinkedDoc
where TipoDoc='COM_DPE_RISPOSTA' and StatoDoc <> 'Saved'

union

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
	
	0 as bRead ,
	C.LinkedDoc as IdCom,
	case when C.Tipodoc in ('VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN') then 'Modifica Dati Registrazione' else C.Titolo end as Name,
	C.DataInvio as DataCreazione,
	 C.TipoDoc as OPEN_DOC_NAME,
	'2' AS StatoGD,
	'1' as OpenDettaglio,
	C2.DataInvio as DataCreazione1,
	C2.Protocollo as ProtocolloRiferimento
	

from  CTL_DOC C with(nolock)
	  inner join CTL_DOC C2 with(nolock) on C.LinkedDoc=C2.ID	  
where C.TipoDoc in ('PDA_COMUNICAZIONE_RISP','PDA_COMUNICAZIONE_OFFERTA_RISP','VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN')
	
	and C.StatoDoc <> 'Saved'



GO
