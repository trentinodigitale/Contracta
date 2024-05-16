USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GROUP_ACQUISTI]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[GROUP_ACQUISTI] as
select profiliutente.idpfu as idOwner , LFN_id as Folder , 1 as  display ,

--	case 
--		when LFN_id = 'DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB' then FSP.c
--		when LFN_id = 'DASHBOARD_VIEW_BANDILAVORIPUBBLICI' then FSU.c
--		else Number 
--	end as 
	case when Number=0 then null else Number end as Number

from  
	profiliutente  CROSS JOIN 
	--( select count (*) as c from  DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB ) as FSP ,
	--( select count (*) as c from  DASHBOARD_VIEW_BANDILAVORIPUBBLICI ) as FSU ,
	LIB_Functions  RIGHT OUTER JOIN

	( 
			select   count( * ) as Number , CAST( DOC_OWNER AS VARCHAR ) + '_DASHBOARD_VIEW_CONVENZIONI_MONITOR_FORN' as ID_G
					from DASHBOARD_VIEW_CONVENZIONI_MONITOR_FORN 
					where StatoConvenzione ='Pubblicato'
					group by DOC_OWNER 

		union all

			select   count( * ) as Number , CAST( idpfu AS VARCHAR ) + '_DASHBOARD_VIEW_ORDINE_DA_CONVENZIONE' as ID_G
					--from DASHBOARD_VIEW_ORDINE_DA_CONVENZIONE 
						from Document_Ordine o ,ProfiliUtente 
						where IdAziDest = pfuidazi
					group by idpfu 

		union all

			select   count( * ) as Number , CAST( idDestinatario AS VARCHAR ) + '_DASHBOARD_VIEW_BOZZA_FORN' as ID_G
					from DASHBOARD_VIEW_BOZZA_FORN 
					--where StatoConvenzione ='Pubblicato'
					group by idDestinatario 


		union all
			
		select   sum( 
					case when Bread = 1 then 1 else 0 end 
					 )as Number   ,CAST( idDestinatario AS VARCHAR ) + '_DASHBOARD_VIEW_PREVENTIVO_IA' as ID_G
				from DASHBOARD_VIEW_PREVENTIVO_IA 
				--where Bread ='1'
				group by idDestinatario
				
				
		--union all
			
		--	select   count( * ) as Number , CAST( idDestinatario AS VARCHAR ) + '_DASHBOARD_VIEW_PREVENTIVO_FORN' as ID_G
		--			from DASHBOARD_VIEW_PREVENTIVO_FORN 
		--			--where StatoConvenzione ='Pubblicato'
		--			group by idDestinatario 

				
				
	) as bb  ON ID_G = CAST( idPfu AS VARCHAR ) + '_' + LFN_id 

where LFN_GroupFunction = 'GROUP_ACQUISTI' 









GO
