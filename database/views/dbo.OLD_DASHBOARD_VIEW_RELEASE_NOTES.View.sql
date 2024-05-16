USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_RELEASE_NOTES]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_DASHBOARD_VIEW_RELEASE_NOTES] as
	select 
		ctl_doc.*
		,CV.value as Release
		,convert( varchar(10) , ctl_doc.DataInvio , 121 )   as DataDA 
		,convert( varchar(10) , ctl_doc.DataInvio , 121 )   as DataA 
	from ctl_doc with(NOLOCK)
		left join CTL_DOC_Value CV with(NOLOCK) on cv.IdHeader=id and cv.DSE_ID='INFO' and cv.DZT_Name='Release'
	where TipoDoc='RELEASE_NOTES' and deleted=0

GO
