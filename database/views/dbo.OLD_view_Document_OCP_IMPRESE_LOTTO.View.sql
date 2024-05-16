USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_view_Document_OCP_IMPRESE_LOTTO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_view_Document_OCP_IMPRESE_LOTTO] AS
	select c.id,
			l.* 
		from ctl_doc c with(nolock)
				inner join Document_OCP_LOTTI l with(nolock) on l.idRow = c.LinkedDoc
		where c.tipodoc = 'OCP_IMPRESE_LOTTO'
GO
