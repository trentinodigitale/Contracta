USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ISTANZA_AlboOperaEco_VIEW_DGUE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_ISTANZA_AlboOperaEco_VIEW_DGUE] as

select 
		D.id as idheader,
		D.id as IdRow,
		0 as Row,
		'DISPLAY_DGUE' as DSE_ID,
		'PresenzaDGUE' as DZT_NAME,

		case 
			when ISNULL(CV.value,'') <>  'si' and ISNULL(C.SIGN_ATTACH,'')  <> '' and D.statofunzionale <> 'inLavorazione' then 'si'
			else ISNULL(CV.value,'') 
		end as Value
	
	from CTL_DOC D with(nolock)
		left join CTL_DOC_Value CV with(nolock) on CV.IdHeader=LinkedDoc and DSE_ID='DGUE' and DZT_Name='PresenzaDGUE'
		left join CTL_DOC C with(nolock) on D.id=C.LinkedDoc and  C.TipoDoc='MODULO_TEMPLATE_REQUEST' and D.deleted = 0 

union 

select 
		CV.id as idheader,
		CV.id as IdRow,
		0 as Row,
		'DISPLAY_DGUE' as DSE_ID,
		'Allegato' as DZT_NAME,
		ISNULL(C.SIGN_ATTACH,'') as Value

	from CTL_DOC C with(nolock)
		left join CTL_DOC CV with(nolock) on CV.id=C.LinkedDoc 

	where C.TipoDoc='MODULO_TEMPLATE_REQUEST'

GO
