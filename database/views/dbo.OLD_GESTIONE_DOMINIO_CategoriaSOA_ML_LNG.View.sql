USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_GESTIONE_DOMINIO_CategoriaSOA_ML_LNG]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD_GESTIONE_DOMINIO_CategoriaSOA_ML_LNG] AS 

select 
		'CategoriaSOA' as [DMV_DM_ID],  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Module], [DMV_Deleted], lngSuffisso as ML_LNG
	from 
	(
		select [DMV_DM_ID],  [DMV_Cod], [DMV_Father], [DMV_Level], cast ( isnull( m1.ML_Description,DMV_DescML)  as nvarchar(max)) as DMV_DescML, 	
			   [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Module], [DMV_Deleted], lngSuffisso
			from LIB_DomainValues  with(nolock) 
				cross join lingue lng with(nolock) 
				left outer join LIB_Multilinguismo m1 with (nolock) on DMV_DescML=m1.ML_KEY and m1.ML_LNG = lngSuffisso 	
				left join CTL_doc d with(nolock) on d.tipodoc = 'GESTIONE_DOMINIO' and d.deleted = 0 and d.Statofunzionale = 'Confermato' and d.jumpCheck = 'GerarchicoSOA'
			where
				lng.lngdeleted = 0 and  
				dmv_dm_id = 'CategoriaSOA' and d.id is null

		union all 

		--select v.[DMV_DM_ID],  v.[DMV_Cod], v.[DMV_Father], v.[DMV_Level], isnull( l.[DMV_DescML] , v.[DMV_DescML] ) as [DMV_DescML], v.[DMV_Image], v.[DMV_Sort], v.[DMV_CodExt], v.[DMV_Module], v.[DMV_Deleted],lngSuffisso
		--	from CTL_doc d with(nolock) 
		--		inner join ctl_DomainValues v with(nolock) on v.idheader = d.id and v.DMV_DM_ID = 'DOMINIO' 
		--		cross join lingue lng with(nolock) 
		--		left join ctl_DomainValues l with(nolock) on l.idheader = d.id and L.DMV_DM_ID = 'LNG_DESC' and l.[DMV_Cod] = v.[DMV_Cod]  and l.dmv_lng = lngSuffisso 
	
		--	where
		--		lng.lngdeleted = 0 and   
		--		d.tipodoc = 'GESTIONE_DOMINIO' and d.deleted = 0 and d.Statofunzionale = 'Confermato' and d.jumpCheck = 'GerarchicoSOA'


			select 
					DMV_DM_ID , 
					DMV_COD , 
					DMV_Father ,
					DMV_Level ,
					DMV_DescML , 
					DMV_Image , 
					DMV_Sort , 
					DMV_CodExt  , 
					DMV_Module , 
					DMV_Deleted , 
					ML_LNG

				from GerarchicoSOA_ML_LNG as D
					inner join (	
									SELECT max( dmv_level )   as m_Level from GerarchicoSOA_ML_LNG 
								) as B on D.DMV_Level < m_Level
					cross join CTL_doc g with(nolock) 
					where g.tipodoc = 'GESTIONE_DOMINIO' and g.deleted = 0 and g.Statofunzionale = 'Confermato' and g.jumpCheck = 'GerarchicoSOA'



	) as a 
	where 1 = 1 
GO
