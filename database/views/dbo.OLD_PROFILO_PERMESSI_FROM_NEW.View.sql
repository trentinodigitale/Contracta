USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PROFILO_PERMESSI_FROM_NEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_PROFILO_PERMESSI_FROM_NEW] as 

	select 
		-1 as ID_FROM
		, [LFN_PosPermission] as Pos
		, Title as Descrizione
		, PAth
		, 0 as [Check]
	from DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI
GO
