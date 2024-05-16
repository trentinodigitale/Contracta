USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_Document_OCP_LOTTO_AGGIUDICATO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_Document_OCP_LOTTO_AGGIUDICATO] AS
	select c.id,
			l.* 
		from ctl_doc c with(nolock)
				inner join Document_OCP_LOTTI_AGGIUDICATI l with(nolock) on l.idRow = c.LinkedDoc
		where c.tipodoc = 'OCP_IMPRESE_AGGIUDICATARIE'
GO
