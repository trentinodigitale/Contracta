USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_OFO_FORN]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_OFO_FORN] as

	select d.*
			,o.*
			,p.IdPfu as [owner]
		from CTL_DOC d  with (nolock)
				inner join ProfiliUtente p with(nolock) on p.pfuIdAzi = d.Destinatario_Azi
				inner join document_ofo o with(nolock) on o.idHeader = d.Id
		where d.deleted = 0 and d.TipoDoc in ( 'OFO' ) 

		




GO
