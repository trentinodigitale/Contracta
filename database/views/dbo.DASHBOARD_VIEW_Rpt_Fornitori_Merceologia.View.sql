USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Fornitori_Merceologia]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[DASHBOARD_VIEW_Rpt_Fornitori_Merceologia] as

select Periodo,TipoUtente,Territorio,ClasseMerce2,ClasseMerceDesc,ClasseMerceDesc_Sort,SUM(Qta) as Qta  
from 
(
--- Tutti i fornitori registrati o iscritti a 1/più classi merceologiche

SELECT distinct tAziende.IdAzi, 
	aziRagioneSociale,
	DMV_Cod_Level2		as ClasseMerce2,
	v.DMV_DescML as ClasseMerceDesc,
	v.DMV_DescML as ClasseMerceDesc_Sort,
	Territorio,
	Case (cast( isnull( d2.vatValore_FT , '0' ) as int ))
	when 0 then 'F'
		else 'FI'
	end	as TipoUtente,	
	Case (cast( isnull( d2.vatValore_FT , '0' ) as int ))
	when 0 then		-- fornitore registrato con classe
		convert(varchar(7) , 
				(case when Year(aziDataCreazione) <= '2010' 
					then '2010-12-01' 
					else 
						aziDataCreazione
				end),
				20 )
		else		-- fornitore iscritto
		convert( varchar(7) , 
				(case when cast(Year(d3.vatValore_FT) as char(4)) <= '2010'
					then '2010-12-01' else 
					cast(isnull(d3.vatValore_FT, aziDataCreazione) as datetime)
----					cast(d3.vatValore_FT as datetime)
				end),
				20 )
	end	as Periodo,	
	1 as Qta
	FROM        Aziende tAziende with(nolock)
	INNER JOIN Province
		ON rtrim(tAziende.aziProvinciaLeg) like Province.Denominazione
		or rtrim(tAziende.aziProvinciaLeg) = Province.Sigla
	INNER JOIN DM_Attributi ON tAziende.IdAzi = DM_Attributi.lnk 
	INNER JOIN ClassiMerceologiche_Father2 ON DM_Attributi.vatValore_FT = ClassiMerceologiche_Father2.DMV_Cod 
	INNER JOIN ClassiMerceologiche v ON ClassiMerceologiche_Father2.DMV_Cod_Level2 = v.DMV_Cod 
	left outer join dm_attributi d2 on d2.lnk = tAziende.idazi and d2.dztnome = 'CARBelongTo' and d2.idApp = 1
	left outer join dm_attributi d3 on d3.lnk = tAziende.idazi and d3.dztnome = 'sysHabilitStartDate' and d3.idApp = 1
	WHERE     (DM_Attributi.idApp = 1) AND (DM_Attributi.dztNome = 'ClasseIscriz')
) as v
group by Periodo,TipoUtente,Territorio,ClasseMerce2,ClasseMerceDesc,ClasseMerceDesc_Sort


GO
