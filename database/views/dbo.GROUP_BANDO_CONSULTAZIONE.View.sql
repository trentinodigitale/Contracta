USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GROUP_BANDO_CONSULTAZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[GROUP_BANDO_CONSULTAZIONE] as
	select p.idpfu as idOwner , LFN_id as Folder , 1 as  display ,  Number

	from  
		LIB_Functions with (nolock) cross join 
		profiliutente p with (nolock) 

		left outer join ( 
				select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_PUBB_BANDO_CONSULTAZIONE' as ID_G
						from DASHBOARD_VIEW_PUBB_BANDO_CONSULTAZIONE 
						where Scaduto='0' and bread=1
						group by idPfu 
				
					
		) as bb on  ID_G = CAST( idPfu AS VARCHAR ) + '_' + LFN_id 


	where LFN_GroupFunction = 'GROUP_BANDO_CONSULTAZIONE' 
	

GO
