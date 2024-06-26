USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_ENTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD_DASHBOARD_VIEW_COMUNICAZIONI_RISPOSTA_ENTI] 
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
	'COM_DPE_RISPOSTA_ENTE' as OPEN_DOC_NAME,
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
where TipoDoc='COM_DPE_RISPOSTA_ENTE'


GO
