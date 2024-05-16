USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SCHEDA_ANAGRAFICA_DATI_AGGIUNTIVI_view]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_SCHEDA_ANAGRAFICA_DATI_AGGIUNTIVI_view] as 

	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI' as DSE_ID, 
			0 as Row, 
			dztNome as DZT_Name, 
			vatValore_FT as value
			--case when dztNome = 'ClasseIscriz' then dbo.GetMultiValueAzi(lnk,dztNome)
			--	 when dztNome = 'ClassificazioneSOA' then dbo.GetMultiValueAzi(lnk,dztNome)
			--	  when dztNome = 'SettoriCCNL' then dbo.GetMultiValueAzi(lnk,dztNome)				
				 	
			--	else vatValore_FT 
			--end as Value

		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome not in ('ClasseIscriz','ClassificazioneSOA','SettoriCCNL')

union all
	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI' as DSE_ID, 
			0 as Row, 
			'ClasseIscriz' as DZT_Name, 
			dbo.GetMultiValueAzi(lnk,'ClasseIscriz') as value
		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome  in ('ClasseIscriz')
		group by lnk

union all
	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI' as DSE_ID, 
			0 as Row, 
			'ClassificazioneSOA' as DZT_Name, 
			dbo.GetMultiValueAzi(lnk,'ClassificazioneSOA') as value
		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome  in ('ClassificazioneSOA')
		group by lnk

union all
	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI' as DSE_ID, 
			0 as Row, 
			'SettoriCCNL' as DZT_Name, 
			dbo.GetMultiValueAzi(lnk,'SettoriCCNL') as value
		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome  in ('SettoriCCNL')
		group by lnk

union all

	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI_OE' as DSE_ID, 
			0 as Row, 
			dztNome as DZT_Name, 
			vatValore_FT as value
			--case when dztNome = 'ClasseIscriz' then dbo.GetMultiValueAzi(lnk,dztNome)
			--	 when dztNome = 'ClassificazioneSOA' then dbo.GetMultiValueAzi(lnk,dztNome)
			--	  when dztNome = 'SettoriCCNL' then dbo.GetMultiValueAzi(lnk,dztNome)				
				 	
			--	else vatValore_FT 
			--end as Value

		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome not in ('ClasseIscriz','ClassificazioneSOA','SettoriCCNL')


	
union all
	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI_OE' as DSE_ID, 
			0 as Row, 
			'ClasseIscriz' as DZT_Name, 
			dbo.GetMultiValueAzi(lnk,'ClasseIscriz') as value
		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome  in ('ClasseIscriz')
		group by lnk

union all
	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI_OE' as DSE_ID, 
			0 as Row, 
			'ClassificazioneSOA' as DZT_Name, 
			dbo.GetMultiValueAzi(lnk,'ClassificazioneSOA') as value
		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome  in ('ClassificazioneSOA')
		group by lnk

union all
	select distinct 
			--idVat as IdRow, 
			1 as IdRow, 
			lnk as IdHeader, 
			'DATI_AGGIUNTIVI_OE' as DSE_ID, 
			0 as Row, 
			'SettoriCCNL' as DZT_Name, 
			dbo.GetMultiValueAzi(lnk,'SettoriCCNL') as value
		from dbo.DM_Attributi with(nolock)
		where idApp = 1 and dztNome  in ('SettoriCCNL')
		group by lnk
GO
