USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_DOCUMENT_CESSAZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_VIEW_DOCUMENT_CESSAZIONE] as
	select a.*, Destinatario_User as [User], b.value as IdPfuSubentro , c.value as SenzaCessazione,d.Value as Allegato
		from ctl_doc a
				left join ctl_doc_value b with(nolock) ON b.idheader = a.id and b.dse_id = 'SUBENTRATO' and b.DZT_Name = 'IdPfuSubentro'
				left join ctl_doc_value c with(nolock) ON c.idheader = a.id and c.dse_id = 'SUBENTRATO' and c.DZT_Name = 'SenzaCessazione'
				left join ctl_doc_value d with(nolock) ON d.idheader = a.id and d.dse_id = 'SUBENTRATO' and d.DZT_Name = 'allegato'



GO
