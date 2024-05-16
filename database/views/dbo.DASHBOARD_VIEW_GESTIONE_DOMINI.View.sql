USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_GESTIONE_DOMINI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_GESTIONE_DOMINI] AS
select 
	C.*
	from ctl_doc C with(nolock)
		where tipodoc='GESTIONE_DOMINIO'-- and StatoFunzionale <> 'InLavorazione'
		and Deleted=0


GO
