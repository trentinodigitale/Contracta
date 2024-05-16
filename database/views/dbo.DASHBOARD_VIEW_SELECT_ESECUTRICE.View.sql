USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_SELECT_ESECUTRICE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_SELECT_ESECUTRICE] as 
select a.idRow ,a.idAzi as idAziPartecipante , b.idAziEsecutrice , a.ProtocolloBando from 
	Document_Consorzio_Bando as a
		left outer join Document_Aziende_Esecutrici as b on a.idRow = idHeader AND Esecutrice = 'si'

GO
