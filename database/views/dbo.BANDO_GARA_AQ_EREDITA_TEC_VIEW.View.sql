USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_GARA_AQ_EREDITA_TEC_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BANDO_GARA_AQ_EREDITA_TEC_VIEW] AS
select 
		CV.*
	from CTL_DOC_Value CV with(NOLOCK)
	where CV.DSE_ID='AQ_EREDITA_TEC'

UNION ALL

select 
		CV.idrow,
		CV.idheader,
		'AQ_EREDITA_TEC' as DSE_ID,
		0 as Row ,
		'NotEditable1' as DZT_Name,		 
		case when D.TipoProceduraCaratteristica = 'RilancioCompetitivo' then ' PunteggioTecMaxEredit PunteggioTecMinEredit ' else '' end as Value
		
	from CTL_DOC_Value CV with(NOLOCK)		
		left join document_bando D with(NOLOCK) on D.idHeader=CV.IdHeader
	where CV.DSE_ID='AQ_EREDITA_TEC' and CV.DZT_Name='PunteggioTecMaxEredit'

GO
