USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GROUP_ALBO]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[GROUP_ALBO] as
	select p.idpfu as idOwner , LFN_id as Folder , 1 as  display ,  Number

	from  
		LIB_Functions cross join 
		profiliutente p 

		left outer join ( 
				select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI' as ID_G
						from DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORI 
						where Scaduto='0' and bread=1
						group by idPfu 
				
					
		) as bb on  ID_G = CAST( idPfu AS VARCHAR ) + '_' + LFN_id 


	where LFN_GroupFunction = 'GROUP_ALBO' 


GO
