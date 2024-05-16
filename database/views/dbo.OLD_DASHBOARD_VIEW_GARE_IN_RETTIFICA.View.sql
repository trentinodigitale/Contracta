USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_GARE_IN_RETTIFICA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_GARE_IN_RETTIFICA] 
as 
	SELECT 
		c.*, Azienda as AZI_Ente
		,tipoDoc as OPEN_DOC_NAME
		,case
			when cr.REL_idRow is null then 'no'
			else 'si'
		 end as Bando_gara_edit
	From CTL_DOC C with (nolock) 

		left join ctl_relations cr with (nolock) on c.Id=cr.REL_ValueInput and cr.REL_Type= 'GARE_IN_MODIFICA_O_RETTIFICA' and cr.REL_ValueOutput='OPEN'
		
	where TipoDoc in ('bando_gara','bando_semplificato') and deleted=0 and StatoFunzionale='InRettifica'



GO
