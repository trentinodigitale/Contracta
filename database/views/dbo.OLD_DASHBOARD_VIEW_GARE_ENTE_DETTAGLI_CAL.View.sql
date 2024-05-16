USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL] as 
select  
	P.idpfu, 
	DASHBOARD_VIEW_GARE_DETTAGLI_CAL.*
	from DASHBOARD_VIEW_GARE_DETTAGLI_CAL
		INNER JOIN ProfiliUtente P with(nolock) on P.Pfuidazi=Azi_Ente
GO
