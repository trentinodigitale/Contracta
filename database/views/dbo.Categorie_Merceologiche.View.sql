USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Categorie_Merceologiche]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[Categorie_Merceologiche] as 


	SELECT  DMV_DM_ID
		, DMV_DM_ID + '_' + DMV_Cod as      DMV_Cod      
		, DMV_DM_ID + '_' + DMV_Father     as    DMV_Father
		, DMV_Level              
		, DMV_DescML 
		, 'node.gif' as DMV_Image
		, DMV_Sort 
		, DMV_Module
		, DMV_CodExt 
		, DMV_Deleted
		--FROM LIB_DomainValues with(nolock)
		from GESTIONE_DOMINIO_A_CND with(nolock)
		--WHERE DMV_DM_ID = 'A_CND'  and ISNULL(DMV_Father  ,'') <> ''
		WHERE ISNULL(DMV_Father  ,'') <> ''
		
				    
	union ALL
		
	SELECT DMV_DM_ID
		, DMV_DM_ID + '_' + DMV_Cod    as      DMV_Cod     
		,DMV_DM_ID + '_' +  DMV_Father   as DMV_Father      
		, DMV_Level              
		, DMV_DescML 
		, 'node.gif' as DMV_Image
		, DMV_Sort 
		,DMV_Module
		, DMV_CodExt 
		, DMV_Deleted
		--FROM LIB_DomainValues  with(nolock)
		from GESTIONE_DOMINIO_A_ATC with(nolock)
		--WHERE DMV_DM_ID = 'A_ATC'  and ISNULL(DMV_Father  ,'') <> ''
		WHERE  ISNULL(DMV_Father  ,'') <> ''
			  
		
	union ALL
	
	SELECT  DMV_DM_ID
		, DMV_DM_ID + '_' + DMV_Cod  as      DMV_Cod       
		, DMV_DM_ID + '_' + DMV_Father   as    DMV_Father      
		, DMV_Level              
		, DMV_DescML 
		, 'node.gif' as DMV_Image
		, DMV_Sort 
		,DMV_Module
		, DMV_CodExt 
		, DMV_Deleted
		FROM LIB_DomainValues  with(nolock)
		WHERE 
			DMV_DM_ID = 'CODICE_CPV'  
			and ISNULL(DMV_Father  ,'') <> ''  

	union ALL
	
	SELECT DMV_DM_ID
		, DMV_DM_ID + '_' + DMV_Cod   as      DMV_Cod
		, DMV_DM_ID + '_' + DMV_Father   as    DMV_Father      
		, DMV_Level              
		, DMV_DescML 
		, 'node.gif' as DMV_Image
		, DMV_Sort 
		,DMV_Module
		, DMV_CodExt 
		, ISNULL(DMV_Deleted,0) as DMV_Deleted
		--FROM LIB_DomainValues  with(nolock)
		FROM GerarchicoSOA with(nolock)
		WHERE 
			--DMV_DM_ID = 'GerarchicoSOA'  
			--and 
			ISNULL(DMV_Father  ,'') <> ''
			
	  
		
			


GO
