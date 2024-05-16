USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTA_HD]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_RICHIESTA_HD] as

	select 
        d.*
              ,
		case when r.DOC_NAME is not null then '0' else '1'end as bRead 
	  , val.value as ticketafs
        
	from CTL_DOC d
			left outer join 
		CTL_DOC_value val
			ON d.id = val.idheader and dse_id = 'TESTATA_SEGNALAZIONE' and val.dzt_name = 'ticketAFS'
			left outer join
	     CTL_DOC_READ r 
		     on r.DOC_NAME = d.TipoDoc and r.id_Doc = d.id and r.doc_name = 'RICHIESTA_HD' and r.idpfu = d.idpfu

	 where d.deleted = 0 and d.TipoDoc =  'RICHIESTA_HD' 
GO
