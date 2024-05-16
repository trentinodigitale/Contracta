USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONTROLLI_OE_EFFETTUATI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_CONTROLLI_OE_EFFETTUATI]  AS
select 
	*,
	TipoDoc as OPEN_DOC_NAME

	from CTL_DOC with(nolock)
	where TipoDoc='ESITO_CONTROLLI_OE' and StatoFunzionale in ('InProtocollazione','Protocollato')
GO
