USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_SIMOG_LOGIN_RPNT]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_SIMOG_LOGIN_RPNT] AS
	SELECT a.*,
			b.Value as UserRUP
		FROM CTL_DOC a with(nolock)
				left join ctl_doc_value b with(nolock) on b.IdHeader = a.id and b.DSE_ID = 'DATI' and b.DZT_Name = 'UserRUP'
		where a.TipoDoc = 'SIMOG_RPNT' and a.Deleted = 0
GO
