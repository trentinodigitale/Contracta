USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_PREGARA_WORK_FLOW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_PREGARA_WORK_FLOW] AS
select 
	C.*,
	PR.APS_IdPfu as owner,
	PR.APS_Date as Data_Sort
from ctl_doc C  with(nolock)
		inner join PREGARA_WORKFLOW_VIEW  PR on C.Id=PR.APS_ID_DOC and PR.APS_State='InCharge'
	where C.TipoDoc='PREGARA' and ( idpfuInCharge = 0 or ISNULL(idPfuInCharge,'') = '' ) and C.Deleted=0
GO
