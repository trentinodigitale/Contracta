USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GROUP_COMUNICAZIONI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[GROUP_COMUNICAZIONI] as
select profiliutente.idpfu as idOwner , LFN_id as Folder , 1 as  display ,

--	case 
--		when LFN_id = 'DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB' then FSP.c
--		when LFN_id = 'DASHBOARD_VIEW_BANDILAVORIPUBBLICI' then FSU.c
--		else Number 
--	end as 
	null as Number

from  
	LIB_Functions  ,
	profiliutente  
--,
	--( select count (*) as c from  DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB ) as FSP ,
	--( select count (*) as c from  DASHBOARD_VIEW_BANDILAVORIPUBBLICI ) as FSU ,

--	( 
--			select   count( * ) as Number , CAST( owner AS VARCHAR ) + '_DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI' as ID_G
--					from DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI
--					where bread=1
--					group by owner 
--
--				
--	) as bb 

where LFN_GroupFunction = 'GROUP_COMUNICAZIONI' 


GO
