USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PUBBLICITA_LEGALE_OWNER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_PUBBLICITA_LEGALE_OWNER] AS
select 
	ctl_doc.*,
	IdPfu as Owner,
	Tipologia,
	Protocol,
	cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
	cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
	pratica
	from ctl_doc with(nolock)
		LEFT JOIN Document_RicPrevPubblic With(nolock) ON CTL_DOC.ID=Document_RicPrevPubblic.idheader
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=ctl_doc.id
	where TipoDoc='PUBBLICITA_LEGALE' and ctl_doc.Deleted=0

GO
