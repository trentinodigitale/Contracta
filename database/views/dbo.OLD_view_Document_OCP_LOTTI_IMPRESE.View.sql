USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_view_Document_OCP_LOTTI_IMPRESE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_view_Document_OCP_LOTTI_IMPRESE] as 

	select  [idHeader], 
			[NumeroLotto], 
			[W3OGGETTO2], 
			[W3CIG],
			c.TipoDoc as OPEN_DOC_NAME,
			c.id as idRow
		from Document_OCP_LOTTI I with(nolock)
				INNER JOIN CTL_DOC c with(nolock) on c.LinkedDoc = i.idrow and c.tipodoc = 'OCP_IMPRESE_LOTTO' and c.Deleted = 0
GO
