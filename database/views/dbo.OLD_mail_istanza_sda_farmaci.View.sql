USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_mail_istanza_sda_farmaci]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_mail_istanza_sda_farmaci]  as 
	select * , dbo.GetDocAPS_NOTE ( mail.iddoc ,mail.tipoDocumento ) as APS_NOTE ,  mail.iddoc as APS_ID_DOC , mail.tipoDocumento as APS_Doc_Type 
		from MAIL_DOCUMENT mail with (nolock)
			
			--left join (
			
			--	select A.APS_NOTE,A.APS_ID_DOC, a.APS_Doc_Type 
			--	    from CTL_APPROVALSteps A with (nolock) , 
			
			--		   (Select MAX(APS_ID_ROW) as APS_ID_ROW,APS_ID_DOC 
			--			  from CTL_APPROVALSteps with (nolock) 
			--			  where APS_State <> 'Sent' group by APS_ID_DOC ) B 

			--	    where A.APS_ID_ROW=B.APS_ID_ROW ) C  on mail.iddoc=C.APS_ID_DOC and mail.tipoDocumento = c.APS_Doc_Type 


GO
