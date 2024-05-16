USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_IMPORT_FORNITORI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_IMPORT_FORNITORI] AS
select 
	C.*
	from ctl_doc C with(nolock)
		where tipodoc='IMPORT_FORNITORI'-- and StatoFunzionale <> 'InLavorazione'
		and Deleted=0




GO
