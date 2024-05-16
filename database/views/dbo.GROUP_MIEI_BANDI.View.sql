USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GROUP_MIEI_BANDI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[GROUP_MIEI_BANDI] as
select T.idpfu as idOwner , LFN_id as Folder , 1 as  display ,

	case 
		when LFN_id = 'DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB' then null--FSP.c
		when LFN_id = 'DASHBOARD_VIEW_BANDILAVORIPUBBLICI' then null--FSU.c
		else Number 
	end as Number

from  
	--LIB_Functions  ,
	--profiliutente  ,
	--( select count (*) as c from  DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB ) as FSP ,
	--( select count (*) as c from  DASHBOARD_VIEW_BANDILAVORIPUBBLICI ) as FSU ,
   ( 

		
		
			select   count( * ) as Number , CAST( umidPfu AS VARCHAR ) + '_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV' as ID_G
			
				from Tab_utenti_messaggi  
					inner join TAB_MESSAGGI_FIELDS on IdMsg = umIdMsg
				where ( (ISubType in ( 25 ,37 , 64) 
						    and (Tipoappalto in ('15494' , '15495' , '15496')) )
						or
				
						(ISubType =168
						    and (Tipoappalto in ('15494' , '15495' , '15496') and tipobando<>3 ) 
						)
					  )
					  
					and [read]='1'		and uminput=0
					and umstato=0
					and umidpfu > 0
				group by umidPfu 
	
--funzione orginale
--			select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV' as ID_G
--					from DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV 
--					where 
--						--msgISubType in ( 25 ,37 , 64 ,168 ) and (Tipologia in ( 1 , 2 , 3 ) )
--					 bread=1
--						and (
--								(msgISubType in ( 25 ,37 , 64 ) and (Tipologia in (1,2,3)))
--								or 
--								(msgISubType = 168 and (Tipologia in (1,2,3)) and TipoBando <> 3 )
--							)
--					group by idPfu 
--funzione orginale					
				
					
--		UNION ALL	
--		
--			select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_BANDILAVORIPRIVATI' as ID_G
--					from DASHBOARD_VIEW_BANDILAVORIPRIVATI
--					where msgISubType in ( 168 )  
--					and bread=1
--					group by idPfu 
			
				
	) as bb right outer join  
   (
	select CAST( idPfu AS VARCHAR ) + '_' + LFN_id as KEYID ,idPfu,LFN_id,LFN_GroupFunction from LIB_Functions,profiliutente
	where LFN_GroupFunction = 'GROUP_MIEI_BANDI'
	) T 
	on ID_G = T.KEYID	
	and T.LFN_GroupFunction = 'GROUP_MIEI_BANDI'


GO
