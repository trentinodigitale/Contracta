USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_SEMP_OFF_EVAL_CRITERI_ECO_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD2_BANDO_SEMP_OFF_EVAL_CRITERI_ECO_VIEW] as


select v.IdRow
	, l.id as IdHeader
	,'CRITERI_ECO' as DSE_ID
	, v.Row
	, v.DZT_Name
	,isnull( c.Value , v.Value ) as Value
	
	from document_microlotti_dettagli l
		inner join 	CTL_DOC_Value v on l.idheader = v.idHeader and v.DSE_ID = 'CRITERI_ECO'
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID = 'CRITERI_ECO' and v.DZT_Name = c.DZT_Name


GO
