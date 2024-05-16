USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DWH_GET_CODE_LIST]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_DWH_GET_CODE_LIST] as 

	select dmv_dm_id as Dominio,
			b.dmv_cod as Codice , 
			b.dmv_father as Path, 
			b.dmv_level as Livello, 
			b.DMV_DescML as Descrizione , 
			isnull( b.DMV_Deleted , 0 ) as Cancellato, 
			B.DMV_CodExt as Codice_Ext
		from lib_domainvalues b with(nolock) 
		where b.dmv_dm_id in ( 'DescTipoProcedura', 'UserRole', 'StatoFunzionale', 'StatoRiga', 'Tipologia')

	UNION ALL

	select 'Profilo' as Dominio,
			codice as Codice , 
			'' as Path, 
			0 as Livello, 
			Descrizione , 
			case 	when codice like 'RapLeg%'
				then 1
				else 0 
			 end as Cancellato, 
			Codice as Codice_Ext
		from Profili_Funzionalita 
		where deleted = 0 and ISNULL(codice,'') <> 'ProfiloBase'
GO
