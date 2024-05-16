USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_SEMP_OFF_EVAL_CRITERI_ECO_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BANDO_SEMP_OFF_EVAL_CRITERI_ECO_VIEW] as


select v.IdRow
	, l.id as IdHeader
	,'CRITERI_ECO' as DSE_ID
	, v.Row
	, v.DZT_Name
	,isnull( c.Value , v.Value ) as Value
	
	from document_microlotti_dettagli l
		inner join 	CTL_DOC_Value v on l.idheader = v.idHeader and v.DSE_ID = 'CRITERI_ECO'
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID IN (  'CRITERI_ECO' , 'CRITERI_ECO_LOTTO' ) and v.DZT_Name = c.DZT_Name

GO
