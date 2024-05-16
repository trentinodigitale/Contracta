USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_BANDO_QF]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_BANDO_QF] as

	select 

		TipoDoc as OPEN_DOC_NAME,
		id,
		d.idpfu,
		iddoc,
		TipoDoc,
		StatoDoc,
		Data,
		Protocollo,
		PrevDoc,
		Deleted,
		Body as Titolo,
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
		ReceivedQuesiti,
		id as idbando,
		p.idpfu as owner


	from CTL_DOC  d  with (nolock)

		inner join dbo.Document_Bando with (nolock) on id = idheader
		inner join ProfiliUtente p with (nolock) on pfuidazi = azienda

			where deleted = 0 and TipoDoc in ( 'BANDO_QF' )






GO
