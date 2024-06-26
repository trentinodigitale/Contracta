USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_LIB_ModelAttributeProperties_Customized]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE view [dbo].[OLD_LIB_ModelAttributeProperties_Customized] as

	select 

			MAP_ID, 
			MAP_MA_MOD_ID, 
			MAP_MA_DZT_Name, 
			MAP_Propety, 
			isnull( p.Valore,  MAP_Value ) as MAP_Value ,
			MAP_Module 

		from lib_modelattributeproperties l with( nolock ) 
			left join CTL_Parametri p with( nolock ) on l.MAP_MA_MOD_ID = p.[Contesto] and l.MAP_MA_DZT_Name = p.Oggetto and l.MAP_Propety = p.Proprieta and p.deleted = 0 

	union all 

	select 

			-id as MAP_ID, 
			Contesto as MAP_MA_MOD_ID, 
			Oggetto as MAP_MA_DZT_Name, 
			Proprieta as MAP_Propety, 
			p.Valore as MAP_Value ,
			'' as MAP_Module 

		from  CTL_Parametri p with( nolock )
			left outer join lib_modelattributeproperties l with( nolock ) on l.MAP_MA_MOD_ID = p.[Contesto] and l.MAP_MA_DZT_Name = p.Oggetto and l.MAP_Propety = p.Proprieta
		where l.MAP_ID is null and p.deleted = 0 


GO
