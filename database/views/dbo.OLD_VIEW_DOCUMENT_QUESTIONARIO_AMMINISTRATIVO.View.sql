USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_DOCUMENT_QUESTIONARIO_AMMINISTRATIVO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW
	[dbo].[OLD_VIEW_DOCUMENT_QUESTIONARIO_AMMINISTRATIVO]
	as

	select 
		Q.*,
		T.StatoFunzionale as StatoFunzionaleLinkedDoc
	from
		CTL_DOC  Q with (nolock)
			inner join ctl_doc T with (nolock) on T.Id=Q.LinkedDoc 
		where 
			Q.TipoDoc ='QUESTIONARIO_AMMINISTRATIVO'
GO
