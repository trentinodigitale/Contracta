USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_PREGARA_TODO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_PREGARA_TODO] AS
select 
	C.*,
	CA.APS_IdPfu as owner,
	APS_Date
	from ctl_doc C  with(nolock)
		inner join CTL_ApprovalSteps CA with(nolock) on CA.APS_ID_DOC=C.Id and CA.APS_Doc_Type=C.TipoDoc and CA.APS_State='InCharge'
	where C.TipoDoc='PREGARA' and C.Deleted=0
GO
