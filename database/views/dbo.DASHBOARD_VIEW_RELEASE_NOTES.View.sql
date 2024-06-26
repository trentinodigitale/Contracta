USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RELEASE_NOTES]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_RELEASE_NOTES] as
	select 
		ctl_doc.*
		,CV.value as Release
		,convert( varchar(10) , ctl_doc.DataInvio , 121 )   as DataDA 
		,convert( varchar(10) , ctl_doc.DataInvio , 121 )   as DataA 
		,cv2.Value as DataPubblicazione
		,convert( varchar(10) , cv2.Value , 121 )   as Datainviodal 
		,convert( varchar(10) , cv2.Value , 121 )   as Datainvioal 
	from ctl_doc with(NOLOCK)
		left join CTL_DOC_Value CV with(NOLOCK) on cv.IdHeader=id and cv.DSE_ID='INFO' and cv.DZT_Name='Release'
		left join CTL_DOC_Value CV2 with(NOLOCK) on cv2.IdHeader=id and cv2.DSE_ID='INFO' and cv2.DZT_Name='DataPubblicazione'
	where TipoDoc='RELEASE_NOTES' and deleted=0


GO
