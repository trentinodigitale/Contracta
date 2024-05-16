USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_PREGARA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OLD2_MAIL_PREGARA] as
select
	
	  d.id as iddoc
	, lngSuffisso as LNG	
	, d.TipoDoc
	, d.Protocollo as Protocollo
	, d.Body

from ctl_doc d with(NOLOCK)
	cross join Lingue with(NOLOCK)	
	where d.TipoDoc='PREGARA'	
	
GO
