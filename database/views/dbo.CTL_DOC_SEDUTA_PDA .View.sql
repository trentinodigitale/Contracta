USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_SEDUTA_PDA ]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[CTL_DOC_SEDUTA_PDA ] AS

select

	C. *
	, value as TipoSeduta
	from
		 ctl_doc C with (nolock)
			inner join ctl_doc_value  with (nolock) on idheader = id and dse_id='DATE' and dzt_name='TipoSeduta'
	where 
		tipodoc='SEDUTA_PDA' 
		

GO
