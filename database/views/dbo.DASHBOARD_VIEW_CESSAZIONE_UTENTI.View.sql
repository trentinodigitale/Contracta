USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CESSAZIONE_UTENTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_CESSAZIONE_UTENTI] AS
select 
	*
	from CTL_DOC with(nolock)
	where TipoDoc='CESSAZIONE_UTENTI' and Deleted=0
GO
