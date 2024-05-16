USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REPORT_AVANZAMENTO_QUESTIONARI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REPORT_AVANZAMENTO_QUESTIONARI]  AS

		select 

			a.id as idmsg,
			b.idazi,
			b.idazi as idazi2,
			b.aziragionesociale as ragsoc,
			x.body as oggetto,
			'questionario_fornitore' as OPEN_DOC_NAME ,
			x.Protocollo as 'ProtocolloBando',
			a.body as oggettoquest,
			a.Protocollo as 'Protocollo',
			a.Data as dataarrivo,
			case when z.pfuNome is null then  dbo.GetUsersChained(a.id) else  z.pfuNome end    as 'utente',
			a.StatoFunzionale ,
			x.id as idbando,
			p.idpfu


				from CTL_DOC a
					inner join aziende b on a.Azienda =b.idazi
					inner join ctl_doc x on x.id=a.LinkedDoc 
					inner join document_bando y on y.idheader=x.Id
					left outer join ProfiliUtente z on z.IdPfu = a.idPfuInCharge 
					inner join ProfiliUtente p on p.pfuIdAzi  = a.Destinatario_Azi 

						where a.Deleted = 0
								and a.TipoDoc = 'questionario_fornitore'






GO
