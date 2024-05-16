USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CONFIG_MODELLI_LOTTI_AMBITO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_CONFIG_MODELLI_LOTTI_AMBITO] as

		select * from ctl_doc_value with(nolock) where dse_id = 'AMBITO'
	
	UNION 

		select 		modello.id as idrow,
					modello.id as idHeader,
					'AMBITO' as DSE_ID,
					0 as row,
					'NotEditable' as Dzt_name,
					case when isnull(modello.LinkedDoc, 0) <> 0 then ' MacroAreaMerc ' 
					else '' 
					end as Value
			from ctl_doc modello with(nolock)
			where tipodoc='CONFIG_MODELLI_LOTTI'
	

GO
