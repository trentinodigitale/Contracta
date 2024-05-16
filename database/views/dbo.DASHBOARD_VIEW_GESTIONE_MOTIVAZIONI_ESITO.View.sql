USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_GESTIONE_MOTIVAZIONI_ESITO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_GESTIONE_MOTIVAZIONI_ESITO] as
select 
	*,
	value as Contesto
	from CTL_DOC with(nolock)
		left join CTL_DOC_Value with(nolock) on IdHeader=id and DSE_ID='SEZ_TECNICA' and DZT_Name='contesto'
	where TipoDoc='GESTIONE_MOTIVAZIONI_ESITO' and Deleted=0

GO
