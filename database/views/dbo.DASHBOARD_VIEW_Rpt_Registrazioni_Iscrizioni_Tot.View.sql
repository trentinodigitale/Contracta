USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_Tot]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_Tot]
as

select
(
	select 1 
)	as id,
(
	select 1 
)	as idHeader,
(
select SUM(Qta) from 
(
	SELECT DISTINCT idazi, 1 as Qta 
		FROM  Aziende with(nolock) 
		WHERE   aziVenditore	<> 2		--- enti 
	 ) as t
) as QtaEntiReg,			--- enti aderenti
(
select SUM(Qta) from 
(
	SELECT DISTINCT idazi, 1 as Qta 
		FROM  Aziende with(nolock) 
		left outer join dm_attributi d2 on d2.lnk = idazi and d2.dztnome = 'CARBelongTo'
		left outer join dm_attributi d3 on d3.lnk = idazi and d3.dztnome = 'sysHabilitStartDate'
		INNER JOIN DM_Attributi d4 ON d4.lnk = IdAzi  and (d4.idApp = 1 AND d4.dztNome = 'ClasseIscriz')
		WHERE   aziVenditore	= 2		--- fornitori
		and d3.vatValore_FT is null		--- non iscritti		
	 ) as u
) as QtaRegTrans,			--- registrati transitori (fornitori con classe merc non iscritti)
(
select SUM(Qta) from 
(
	SELECT DISTINCT tAziende.IdAzi, 1 as Qta
		FROM        Aziende tAziende with(nolock)
		INNER JOIN DM_Attributi ON tAziende.IdAzi = DM_Attributi.lnk 
		INNER JOIN ClassiMerceologiche_Father ON DM_Attributi.vatValore_FT = ClassiMerceologiche_Father.DMV_Cod 
		INNER join dm_attributi d2 on d2.lnk = tAziende.idazi and d2.dztnome = 'CARBelongTo' and d2.idApp = 1
		INNER join dm_attributi d3 on d3.lnk = tAziende.idazi and d3.dztnome = 'sysHabilitStartDate' and d3.idApp = 1
		WHERE     (DM_Attributi.idApp = 1) AND (DM_Attributi.dztNome = 'ClasseIscriz')
		and ClassiMerceologiche_Father.DMV_Cod_Level1 = '1' --- iscritti in albo a classe 1-Generiche
		and d3.vatValore_FT is not null				
	 ) as v
) as QtaIscrClassMerc_1,		--- iscritti in albo a classe 1-Generiche
(
select SUM(Qta) from 
(
	SELECT DISTINCT tAziende.IdAzi, 1 as Qta
		FROM        Aziende tAziende with(nolock)
		INNER JOIN DM_Attributi ON tAziende.IdAzi = DM_Attributi.lnk 
		INNER JOIN ClassiMerceologiche_Father ON DM_Attributi.vatValore_FT = ClassiMerceologiche_Father.DMV_Cod 
		INNER join dm_attributi d2 on d2.lnk = tAziende.idazi and d2.dztnome = 'CARBelongTo' and d2.idApp = 1
		INNER join dm_attributi d3 on d3.lnk = tAziende.idazi and d3.dztnome = 'sysHabilitStartDate' and d3.idApp = 1
		WHERE     (DM_Attributi.idApp = 1) AND (DM_Attributi.dztNome = 'ClasseIscriz')
		and ClassiMerceologiche_Father.DMV_Cod_Level1 = '2' --- iscritti in albo a classe 2-Spese Sanitarie
		and d3.vatValore_FT is not null				
	 ) as Z
) as QtaIscrClassMerc_2		--- iscritti in albo a classe 2-Spese Sanitarie

GO
