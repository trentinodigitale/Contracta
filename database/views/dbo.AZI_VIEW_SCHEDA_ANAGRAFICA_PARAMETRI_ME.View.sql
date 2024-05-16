USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_VIEW_SCHEDA_ANAGRAFICA_PARAMETRI_ME]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_VIEW_SCHEDA_ANAGRAFICA_PARAMETRI_ME] as

select distinct
	lnk as idHeader,
	1 as IdRow,  
	'PARAMETRI_ME' as DSE_ID, 
	0 as Row, 
	dztNome as DZT_Name, 
	case when dztNome = 'Province_Dove_Opera'
		then dbo.GetMultiValueAzi(lnk,'Province_Dove_Opera') 
		else vatValore_FT 
	end as Value

from dm_attributi    with (nolock)
	where dztnome in ( 'Province_Dove_Opera','Fatturato_ultimo_anno','Tempi_Medi_gg_consegna') and idapp = 1
GO
