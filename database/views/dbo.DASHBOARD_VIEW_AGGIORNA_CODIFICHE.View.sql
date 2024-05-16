USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_AGGIORNA_CODIFICHE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[DASHBOARD_VIEW_AGGIORNA_CODIFICHE] as

select 
	*
	from
		ctl_doc with (nolock)
	where tipodoc='AGGIORNA_CODIFICHE' and statofunzionale='Confermato'
GO
