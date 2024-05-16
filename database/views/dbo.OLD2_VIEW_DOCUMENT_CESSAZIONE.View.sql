USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_DOCUMENT_CESSAZIONE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_VIEW_DOCUMENT_CESSAZIONE] as
	select a.*, Destinatario_User as [User], b.value as IdPfuSubentro , c.value as SenzaCessazione
		from ctl_doc a
				left join ctl_doc_value b with(nolock) ON b.idheader = a.id and b.dse_id = 'SUBENTRATO' and b.DZT_Name = 'IdPfuSubentro'
				left join ctl_doc_value c with(nolock) ON c.idheader = a.id and c.dse_id = 'SUBENTRATO' and c.DZT_Name = 'SenzaCessazione'


GO
