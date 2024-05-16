USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Fornitori_Merceologia_sub]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_Rpt_Fornitori_Merceologia_sub] as
--select   aziProvinciaLeg2 , l.dmv_cod as  ClasseIscriz,  'Liv. ' + cast( l.DMV_Level as varchar ) + ' - ' + l.DMV_DescML as Descrizione , convert( varchar(7) , a.aziDataCreazione , 121 ) as AnnoMese --, *
select   aziProvinciaLeg2 , C.dmv_cod as  ClasseIscriz,  'Liv. ' + cast( dg1.dgLivello as varchar ) + ' - ' + ds.dscTesto as Descrizione , convert( varchar(7) , a.aziDataCreazione , 121 ) as AnnoMese --, *
	, case 
		
		when left( aziProvinciaLeg2 , 11  ) = 'M-1-11-ITA-' 
			then 
				case 
					when left( aziProvinciaLeg2 , len( R.DZT_ValueDef) ) = R.DZT_ValueDef then '01'
					else '02'
				end
			else
				'03'
		end as Territorio
		, 1 as Num

	from  (

			select idazi ,  dg2.dgCodiceInterno as dmv_cod , dz.dztIdTid
				from aziende A with(nolock)
					inner join DizionarioAttributi dz with(nolock) on dz.dztNome = 'ClasseIscriz'    AND dztDeleted = 0   
					inner join DM_Attributi DM with(nolock) on DM.idapp = 1 and DM.lnk = A.idazi and DM.dztNome = 'ClasseIscriz'
					inner join DominiGerarchici dg1  with(nolock) on dz.dztIdTid = dg1.dgTipoGerarchia  and dg1.dgDeleted = 0 and dg1.dgCodiceInterno = DM.vatValore_FT 
					inner join DominiGerarchici dg2  with(nolock) on dz.dztIdTid = dg2.dgTipoGerarchia  and dg2.dgDeleted = 0 and left ( dg1.dgPath , len( dg2.dgPath ) ) = dg2.dgPath  and dg2.dgLivello in ( 1,2,3,4)
					where azideleted = 0 
				group by idazi ,  dg2.dgCodiceInterno , dz.dztIdTid

		) as C 
		inner join aziende a  with(nolock) on c.idazi = a.idazi
		--inner join ClasseIscriz l  with(nolock) on  c.dmv_cod = l.dmv_cod
		inner join DominiGerarchici dg1  with(nolock) on c.dztIdTid = dg1.dgTipoGerarchia  and dg1.dgDeleted = 0 and dg1.dgCodiceInterno = c.dmv_cod
		inner join DescsI ds with(nolock) on ds.IdDsc = dg1.dgIdDsc
		left outer join LIB_Dictionary R  with(nolock) on R.DZT_Name = 'SYS_CODICE_REGIONE' 







GO
