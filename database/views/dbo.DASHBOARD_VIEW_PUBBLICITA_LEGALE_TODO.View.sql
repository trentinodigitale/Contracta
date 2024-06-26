USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PUBBLICITA_LEGALE_TODO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[DASHBOARD_VIEW_PUBBLICITA_LEGALE_TODO] AS
select 
	C.*,
	CA.APS_IdPfu as owner,
	APS_Date,
	Tipologia,
	cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
	cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
	Protocol,
	Pratica,
	--TipoAppaltoGara,
	--ProtocolloBando
	c.JumpCheck as Guri_Quotidiani
	from ctl_doc C  with(nolock)
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=c.id
		--inner join Document_Bando with(nolock) on idHeader=id
		inner join CTL_ApprovalSteps CA with(nolock) on CA.APS_ID_DOC=C.Id and CA.APS_Doc_Type=C.TipoDoc and CA.APS_State='InCharge'
		LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader
	where C.TipoDoc='PUBBLICITA_LEGALE' and C.Deleted=0
GO
