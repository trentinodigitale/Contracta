USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_PROFILI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_REP_PROFILI] as 
	
	select Title as Titolo , Path as Titolo_SORT , 'All' as Descrizione , 'XXX' as Profilo_SORT , 1 as AttribTxt1
		from DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI	

	union all 

	select Title as Titolo , Path as titolo_SORT , aziProfilo + '-' + Codice as Descrizione , aziProfilo + '-' + Codice as Profilo_SORT , 1 as AttribTxt1 
		from DASHBOARD_VIEW_ELENCO_FUNZIONI_PERMESSI	
			inner join Profili_Funzionalita on substring( Funzionalita , LFN_PosPermission , 1 ) = '1'

GO
