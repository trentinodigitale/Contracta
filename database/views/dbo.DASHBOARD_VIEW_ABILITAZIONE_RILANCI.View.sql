USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ABILITAZIONE_RILANCI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_ABILITAZIONE_RILANCI] AS
	select 
		C.id,
		C.Titolo,
		C.protocollo,
		C.DataInvio,
		C.StatoFunzionale,
		C.IdPfu as owner,
		AQ.protocollo as ProtocolloBando,
		AQ.body as Oggetto,
		'AQ_ABILITAZIONE_RILANCIO' as OPEN_DOC_NAME
		from CTL_DOC C with(nolock)
			inner join CTL_DOC AQ with(nolock) on AQ.Id=C.LinkedDoc
		where C.TipoDoc='AQ_ABILITAZIONE_RILANCIO' and C.Deleted=0
GO
