USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ClasseIscriz]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_ClasseIscriz] as 

select * from    [ClasseIscriz_MLNG] where ML_LNG='I'

 --  select [DMV_DM_ID], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted] 
	--from ( 
		
	--		SELECT 
				
	--			'15'                     AS DMV_DM_ID
	--			, dgCodiceInterno         AS DMV_Cod 
	--			, '000.' + dgPath         AS DMV_Father 
	--			, dgLivello               AS DMV_Level 
	--			, dscTesto                AS DMV_DescML 
	--			, CASE dgFoglia 
	--					WHEN 1 THEN 'node.gif' 
	--					ELSE        'folder.gif' 
	--				END                   AS DMV_Image
	--			, 0                       AS DMV_Sort 
	--			, CASE CHARINDEX(' - ', dscTesto)
	--					WHEN 0 THEN '0'
	--					ELSE LEFT(dscTesto, CHARINDEX( ' - ', dscTesto) -  1)
	--				END                   AS DMV_CodExt 
	--			,dgDeleted as dmv_deleted

	--			FROM 

	--				DominiGerarchici with (nolock)
	--					INNER JOIN  DizionarioAttributi with (nolock) ON  dztIdTid = dgTipoGerarchia     
	--					INNER JOIN DescsI  with (nolock) ON  IdDsc = dgIdDsc
	--					left join CTL_doc d with(nolock) on d.tipodoc = 'GESTIONE_DOMINIO' and d.deleted = 0 and d.Statofunzionale = 'Confermato' and d.jumpCheck = 'ClasseIscriz' 

	--			WHERE 
	--				dztNome = 'ClasseIscriz'    
	--				AND dztDeleted = 0     
	--				AND dgLivello <= 4
	--				and  d.id is null 
			
	--		union all 
		
	--		select 

	--			v.[DMV_DM_ID], v.[DMV_Cod], v.[DMV_Father], v.[DMV_Level], isnull( l.[DMV_DescML] , v.[DMV_DescML] ) as [DMV_DescML], v.[DMV_Image], v.[DMV_Sort], v.[DMV_CodExt], v.[DMV_Deleted] 
			
	--			FROM 
				
	--				CTL_doc d with(nolock) 
	--					inner join ctl_DomainValues v with(nolock) on v.idheader = d.id and v.DMV_DM_ID = 'DOMINIO' 
	--					left join ctl_DomainValues l with(nolock) on l.idheader = d.id and L.DMV_DM_ID = 'LNG_DESC' and l.[DMV_Cod] = v.[DMV_Cod] and l.dmv_lng = 'I' 
				
	--			WHERE 
	--				d.tipodoc = 'GESTIONE_DOMINIO' and d.deleted = 0 and d.Statofunzionale = 'Confermato' and d.jumpCheck = 'ClasseIscriz' 

	--	) as a 
	--	where 1 = 1 




GO
