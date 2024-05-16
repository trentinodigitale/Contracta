USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOCUMENT_QUESTIONARIO_AMMINISTRATIVO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW
	[dbo].[VIEW_DOCUMENT_QUESTIONARIO_AMMINISTRATIVO]
	as

	select 
		Q.*,
		T.StatoFunzionale as StatoFunzionaleLinkedDoc
	from
		CTL_DOC  Q with (nolock)
			inner join ctl_doc T with (nolock) on T.Id=Q.LinkedDoc 
		where 
			Q.TipoDoc ='QUESTIONARIO_AMMINISTRATIVO'
			--and isnull(Q.jumpcheck,'')=''
GO
