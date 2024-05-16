USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GROUP_MIEI_INVITI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[GROUP_MIEI_INVITI] as
select T.idpfu as idOwner , T.LFN_id as Folder , 1 as  display ,  Number

from  
	--LIB_Functions , 
	--profiliutente p ,

	( 

-- sostituzione temporanea da migliorare sulla condizione
			select   count( * ) as Number , CAST( umidPfu AS VARCHAR ) + '_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV' as ID_G
				from Tab_utenti_messaggi  --DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV 
					inner join TAB_MESSAGGI_FIELDS on IdMsg = umIdMsg
				where ISubType in ( 21 , 49, 79, 153 , 113, 69 , 75 ,168) 
						    and (Tipoappalto in ('15494' , '15495' , '15496'))
					and [read]='1'		and uminput=0
					and umstato=0
					and umidpfu > 0
				group by umidPfu 

-- funzione originale

--			select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV' as ID_G
--					from DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV 
--					where msgISubType in ( 21 , 49, 79, 153 , 113, 69 , 75 ,168) 
--						    and (Tipologia in (1,2,3))
--					and bread=1
--					group by idPfu 

-- fine funzione originale

--
----			UNION ALL 
----
----			select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_INVITI_LAVORI' as ID_G
----					from DASHBOARD_VIEW_BANDI_LAVORI_PRIV 
----					where msgISubType in ( 168) and Tipologia=2
----					and bread=1
----					group by idPfu 
--	       --UNION ALL 
--	       
--	       --select   count( * ) as Number , CAST( idPfu AS VARCHAR ) + '_DASHBOARD_VIEW_INVITI_FORN_SERV_PRIV' as ID_G
--		   --			from DASHBOARD_VIEW_BANDI_LAVORI_PRIV 
--		   --			where msgISubType in ( 168)  and (Tipologia=1 or Tipologia=3)
--		   --			and bread=1
--		   --			group by idPfu 
--			
				
	) as bb 

	right outer join  
   (
	select CAST( idPfu AS VARCHAR ) + '_' + LFN_id as KEYID ,idPfu,LFN_id,LFN_GroupFunction from LIB_Functions,profiliutente
	where LFN_GroupFunction = 'GROUP_MIEI_INVITI'
	) T 
	on ID_G = T.KEYID	
	and T.LFN_GroupFunction = 'GROUP_MIEI_INVITI'




GO
