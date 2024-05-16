USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CTL_DOC]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_CTL_DOC] as
	select a.*,a.TipoDoc as OPEN_DOC_NAME, a.id as idmsg , b.ProtocolloBando
		from ctl_doc a with(nolock)
				LEFT JOIN Document_Bando b with(nolock) ON a.id = b.idHeader

GO
