USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_GESTIONE_DOMINI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_GESTIONE_DOMINI] AS
select 
	C.*
	from ctl_doc C with(nolock)
		where tipodoc='GESTIONE_DOMINIO' and StatoFunzionale <> 'InLavorazione'




GO
