USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PRESCADUTO_GROUP_MIEI_BANDI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_PRESCADUTO_GROUP_MIEI_BANDI] as
select profiliutente.idpfu as idOwner , LFN_id as Folder , 1 as  display ,

	case 
		when LFN_id = 'DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB' then null--FSP.c
		when LFN_id = 'DASHBOARD_VIEW_BANDILAVORIPUBBLICI' then null--FSU.c
		else Number 
	end as Number

from  
	LIB_Functions  ,
	profiliutente  ,
	--( select count (*) as c from  DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB ) as FSP ,
	--( select count (*) as c from  DASHBOARD_VIEW_BANDILAVORIPUBBLICI ) as FSU ,

	( 
			select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV' as ID_G
					from DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV 
					where msgISubType in ( 25 ,37 , 64 )
					and bread=1
					group by idPfu 
			
				
	) as bb 

where LFN_GroupFunction = 'GROUP_MIEI_BANDI' and ID_G =* CAST( idPfu AS VARCHAR ) + '_' + LFN_id --and ( p.idpfu =* bb.idpfu or bb.idpfu is null )




GO
