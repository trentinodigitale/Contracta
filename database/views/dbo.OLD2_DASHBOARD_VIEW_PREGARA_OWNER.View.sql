USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_PREGARA_OWNER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_PREGARA_OWNER] AS
select 
	*,
	IdPfu as Owner
	from 
	ctl_doc with(nolock)
		where TipoDoc='PREGARA' and Deleted=0
GO
