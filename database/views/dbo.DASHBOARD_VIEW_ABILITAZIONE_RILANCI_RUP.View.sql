USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ABILITAZIONE_RILANCI_RUP]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW  [dbo].[DASHBOARD_VIEW_ABILITAZIONE_RILANCI_RUP] AS 
	select 
		C.id,
		C.Titolo,
		C.protocollo,
		C.DataInvio,
		C.StatoFunzionale,
		d.Value as owner,
		AQ.protocollo as ProtocolloBando,
		AQ.body as Oggetto,
		'AQ_ABILITAZIONE_RILANCIO' as OPEN_DOC_NAME,
		AZ.aziRagioneSociale

		from CTL_DOC C with(nolock)
			inner join CTL_DOC AQ with(nolock) on AQ.Id=C.LinkedDoc
			inner join Aziende AZ with(nolock) on AZ.Idazi=C.Azienda
			inner join CTL_DOC_VALUE d  on C.LinkedDoc = d.idheader and DSE_ID='InfoTec_comune' and DZT_Name = 'UserRUP' 
		where C.TipoDoc='AQ_ABILITAZIONE_RILANCIO' and C.Deleted=0
GO
