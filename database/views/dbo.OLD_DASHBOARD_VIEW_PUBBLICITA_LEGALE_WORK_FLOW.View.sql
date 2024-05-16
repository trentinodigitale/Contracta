USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PUBBLICITA_LEGALE_WORK_FLOW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_PUBBLICITA_LEGALE_WORK_FLOW] AS
select 
	C.*,
	PR.APS_IdPfu as owner,
	PR.APS_Date as Data_Sort,
	Tipologia,
	cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
	cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
	Protocol,
	Pratica	
	from ctl_doc C  with(nolock)
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=c.id
		LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader
		left join PUBBLICITA_LEGALE_WORKFLOW_VIEW  PR on C.Id=PR.APS_ID_DOC and PR.APS_State='InCharge'
	where C.TipoDoc='PUBBLICITA_LEGALE' and ( idpfuInCharge = 0 or ISNULL(idPfuInCharge,'') = '' ) and C.Deleted=0



GO
