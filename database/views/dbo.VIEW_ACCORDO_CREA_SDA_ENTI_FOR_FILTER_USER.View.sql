USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ACCORDO_CREA_SDA_ENTI_FOR_FILTER_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_ACCORDO_CREA_SDA_ENTI_FOR_FILTER_USER] as 

select 

	distinct 

		p.idpfu,
	
		case
			when c.id is null then a.idazi
			else isnull(c1.value,a.idazi)
		end as IdAzi

	from 
		profiliutente p with (nolock)
			cross join aziende a with (nolock)
			left join CTL_DOC c with (nolock) on  c.azienda =  p.pfuidazi and c.TipoDoc = 'ACCORDO_CREA_SDA' and c.StatoFunzionale = 'Inviato'
			left join CTL_DOC_Value  c1 with (nolock) on c1.idheader = c.id and c1.DSE_ID='ENTI' and c1.DZT_Name ='idAzi' 
	where 
		a.azivenditore = 0  and a.azideleted=0 and p.idpfu > 0
GO
