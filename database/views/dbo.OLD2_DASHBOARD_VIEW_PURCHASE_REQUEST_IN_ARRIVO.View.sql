USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_PURCHASE_REQUEST_IN_ARRIVO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_PURCHASE_REQUEST_IN_ARRIVO] AS
	select a.* ,
				b.Applicant,
				a.Azienda as AZI_Ente
		from ctl_doc a with(nolock)
				inner join document_pr b with(nolock) on b.idheader = a.id
		where a.TipoDoc = 'PURCHASE_REQUEST' AND a.Deleted = 0 and a.StatoFunzionale = 'Ricevuto'
GO
