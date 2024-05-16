USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_TEMPLATE_CONTEST_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_TEMPLATE_CONTEST_DOCUMENT_VIEW] as


select  c.id as ID_REQUEST , d.*
	from ctl_doc d with(nolock) 
		left join ctl_doc c with(nolock) on d.id = c.linkeddoc and c.deleted = 0 and c.tipodoc = 'MODULO_TEMPLATE_REQUEST'


GO
