USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_TEMPLATE_MAIL_DETTAGLI_FROM_VIEWER]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_TEMPLATE_MAIL_DETTAGLI_FROM_VIEWER] as
Select 
	C.id as ID_FROM,
	LngSuffisso as LinguaDom,
	M.ML_Description as Template,
	M2.ML_Description as Oggetto
	
	
	
	from 
	CTL_Mail_Template C
	inner join dbo.LIB_Multilinguismo M on C.ML_KEY= M.ML_KEY
	left join dbo.LIB_Multilinguismo M2 on C.ML_KEY_OGGETTO = M2.ML_KEY
	--left join dbo.Document_Template_Mail on C.id=IdHeader	
	inner join Lingue on M.ML_LNG=LngSuffisso	
	where lngdeleted=0 --and M.ML_KEY='MAIL_DOCUMENTO_NON_LETTO_PREVENTIVO_FORN'



GO
