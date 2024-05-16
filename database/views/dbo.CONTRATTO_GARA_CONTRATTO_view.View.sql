USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONTRATTO_GARA_CONTRATTO_view]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create vIEW  [dbo].[CONTRATTO_GARA_CONTRATTO_view] AS
select IdRow,IdHeader,DSE_ID,Row,DZT_Name,value
    from ctl_doc_value  p with(nolock)
	where dse_id = 'CONTRATTO'
	AND DZT_Name <> 'PresenzaListino'
UNION all
 select IdRow,IdHeader,DSE_ID,Row,DZT_Name,CASE WHEN Value='' THEN '0' ELSE Value END AS value
    from ctl_doc_value  p with(nolock)
	where dse_id = 'CONTRATTO'
	AND DZT_Name = 'PresenzaListino'
GO
