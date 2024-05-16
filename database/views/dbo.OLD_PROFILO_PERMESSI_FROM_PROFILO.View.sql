USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PROFILO_PERMESSI_FROM_PROFILO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_PROFILO_PERMESSI_FROM_PROFILO] as 

	select 
		id as ID_FROM
		, [LFN_PosPermission] as Pos
		, Title as Descrizione
		, PAth
		, case  when substring( [Funzionalita] , [LFN_PosPermission] , 1 ) = '1' then 1 else  0 end as [Check]
	from Profili_Funzionalita 
		cross join DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI




GO
