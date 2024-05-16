USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROGRAMMAZIONI_INIZIATIVE_IMPORTAZIONI_EFFETTUATE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_PROGRAMMAZIONI_INIZIATIVE_IMPORTAZIONI_EFFETTUATE] as 
	SELECT
		*
	FROM ctl_doc C with(NOLOCK)
	WHERE TipoDoc = 'CARICA_INIZIATIVE'
		and C.Deleted <> 1

GO
