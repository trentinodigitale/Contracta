USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ELENCO_CF_CERTIFICATI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_ELENCO_CF_CERTIFICATI] as

	select 
		p.*, 
		'CERTIFICATO_UTENTE' AS OPEN_DOC_NAME,
		ISNULL(p.IdRow,0) as id, 
		v2.Value as 'Certificatore', 
		V3.value +' '+ v4.value as 'nome',
		case 
		when p.idheader is null then ' ' 
		else '../Domain/Lente.gif'
		end as FNZ_OPEN
		from ProfiliUtente_Sign_SerialNumber p with(nolock)
			left join ctl_doc c with(nolock)on c.id=p.IdHeader
			--inviduo la riga del documento che fornisce il certificato
			left join CTL_DOC_Value v1 with(nolock) on v1.IdHeader=c.id and v1.DSE_ID='CERTIFICATI' and v1.value=p.SerialNumber and v1.DZT_Name='SerialNumber'
			left join CTL_DOC_Value v2 with(nolock) on v2.IdHeader=c.id and v2.DSE_ID='CERTIFICATI' and v2.Row=v1.Row and v2.DZT_Name='certificatore'
			left join CTL_DOC_Value v3 with(nolock) on v3.IdHeader=c.id and v3.DSE_ID='UTENTE'  and v3.DZT_Name='Nome'
			left join CTL_DOC_Value v4 with(nolock) on v4.IdHeader=c.id and v4.DSE_ID='UTENTE' and v4.DZT_Name='Cognome'

		where isnull( p.Deleted,0)=0

GO
