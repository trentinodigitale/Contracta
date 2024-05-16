USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_Get_Dominio_GEO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DWH_Get_Dominio_GEO] as 

	select 
		b.dmv_cod as Codice , b.dmv_father as Path, b.dmv_level as Livello, isnull( p.dmv_cod , '' ) as linked_cod , b.DMV_DescML as Descrizione , isnull( b.DMV_Deleted , 0 ) as Cancellato
		, B.DMV_CodExt as Codice_Ext
	
		from lib_domainvalues b with(nolock) 
		left join lib_domainvalues p with(nolock) on p.dmv_dm_id = 'GEO' and b.DMV_Father like p.DMV_Father + '%' and b.DMV_Level  = p.DMV_Level + 1 and isnull(  p.DMV_Deleted , 0 ) = 0
		where b.dmv_dm_id = 'GEO'
GO
