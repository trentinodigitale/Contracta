USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PREGARA_OWNER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_PREGARA_OWNER] AS
select 
	ctl_doc.*,
	IdPfu as Owner,
	TipoAppaltoGara

	from ctl_doc with(nolock)
		inner join Document_Bando with(nolock) on idHeader=id
	where TipoDoc='PREGARA' and Deleted=0
GO
