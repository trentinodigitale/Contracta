USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_PDA_COMUNICAZIONE_GENERICA_SEND_REPORT]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[MAIL_PDA_COMUNICAZIONE_GENERICA_SEND_REPORT] as
select
	COM.id as iddoc
	, lngSuffisso as LNG
	, COM.Protocollo 
	, GARA.Protocollo as ProtocolloBando				
	, GARA.Fascicolo as  FascicoloGara
	, A.aziRagioneSociale as EnteAppaltante 
	, convert (varchar, COM.DataInvio, 103)  +  ' ' + convert( varchar , COM.DataInvio , 108 ) as DataInvio
	, COM.Body as Oggetto
	, GARA.Body as OggettoBando
	, dbo.MAIL_PDA_COMUNICAZIONE_GENERICA_SEND_REPORT_RISOLVE_TEMPLATE(COM.id) as Report_Info_Mail
from 
	ctl_doc COM with(nolock)
		cross join Lingue with(nolock) 
		--salgo sulla PDA
		inner join CTL_DOC PDA with(nolock)  on PDA.id = COM.LinkedDoc 
		--salgo sulla GARA
		inner join CTL_DOC GARA with(nolock)  on GARA.id = PDA.LinkedDoc 
		--recupero ragione sociale ente appaltante
		inner join Aziende A with(nolock)  on GARA.Azienda = A.idazi
	 where 
			COM.TipoDoc='PDA_COMUNICAZIONE_GENERICA'
			and (COM.JumpCheck like '%-ESITO_MICROLOTTI' or  COM.JumpCheck like '%-ESITO_DEFINITIVO_MICROLOTTI'
						or  COM.JumpCheck like '%-ESITO' or  COM.JumpCheck like '%-ESITO_DEFINITIVO' ) 
			and COM.StatoFunzionale = 'Inviato'
GO
