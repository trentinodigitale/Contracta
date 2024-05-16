USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_GESTIONE_DOMINIO_MOD_CONSERVAZ]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_GESTIONE_DOMINIO_MOD_CONSERVAZ] as 
	select [DMV_DM_ID], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], 
	[DMV_Module], [DMV_Deleted] from [GESTIONE_DOMINIO_MOD_CONSERVAZ_DOM_ML_LNG] where ML_LNG='I'

--select 
--		[DMV_DM_ID],  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], 		
--			[DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Module], [DMV_Deleted]
--	from 
--	(
--		select [DMV_DM_ID],  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], 		
--				[DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Module], [DMV_Deleted]
--			from LIB_DomainValues  with(nolock) 				
--				left join CTL_doc d with(nolock) on d.tipodoc = 'GESTIONE_DOMINIO' and d.deleted = 0 
--																	and d.Statofunzionale = 'Confermato' 
--																	and d.jumpCheck = 'A_CND'
--			where dmv_dm_id = 'A_CND' and d.id is null

--		union all 

--		select v.[DMV_DM_ID],  v.[DMV_Cod], v.[DMV_Father], v.[DMV_Level], isnull( l.[DMV_DescML] , v.[DMV_DescML] ) as [DMV_DescML], 
--					v.[DMV_Image], v.[DMV_Sort], v.[DMV_CodExt], v.[DMV_Module], v.[DMV_Deleted]
--			from CTL_doc d with(nolock) 
--				inner join ctl_DomainValues v with(nolock) on v.idheader = d.id and v.DMV_DM_ID = 'DOMINIO' 
--				left join ctl_DomainValues l with(nolock) on l.idheader = d.id and L.DMV_DM_ID = 'LNG_DESC' 
--															and l.[DMV_Cod] = v.[DMV_Cod]  and l.dmv_lng = '#LNG#' 
	
--			where  d.tipodoc = 'GESTIONE_DOMINIO' and d.deleted = 0 and d.Statofunzionale = 'Confermato' 
--					and d.jumpCheck = 'A_CND'
--	) as a 
--	where 1 = 1 
--	--order by [DMV_Father]
--GO


GO
