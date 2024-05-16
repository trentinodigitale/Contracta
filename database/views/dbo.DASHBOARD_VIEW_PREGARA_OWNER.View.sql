USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PREGARA_OWNER]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_PREGARA_OWNER] AS
select 
	ctl_doc.*,
	IdPfu as Owner,
	TipoAppaltoGara,
	ProtocolloBando

	from ctl_doc with(nolock)
		inner join Document_Bando with(nolock) on idHeader=id
	where TipoDoc='PREGARA' and Deleted=0
GO
