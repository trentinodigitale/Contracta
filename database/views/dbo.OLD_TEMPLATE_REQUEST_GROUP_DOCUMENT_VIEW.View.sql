USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_TEMPLATE_REQUEST_GROUP_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  view [dbo].[OLD_TEMPLATE_REQUEST_GROUP_DOCUMENT_VIEW] as

	select
			d.*,
			isnull(c1.value,'') as Tooltip,
			isnull(c2.value,'') as Tooltip_UK
		from 
			CTL_DOC d  with (nolock)  
				left join ctl_Doc_value c1 with (nolock) on c1.idheader = id and c1.dse_id = 'TIPOLOGIA' and c1.dzt_name='Tooltip'
				left join ctl_Doc_value c2 with (nolock) on c2.idheader = id and c2.dse_id = 'TIPOLOGIA' and c2.dzt_name='Tooltip_UK'
		where 
			Tipodoc in ( 'TEMPLATE_REQUEST_GROUP' ,'TEMPLATE_REQUEST_GROUP_TOOLTIP')
GO
