USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_SUB_QUESTIONARIO_FABBISOGNI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_MAIL_SUB_QUESTIONARIO_FABBISOGNI] as

select 
	 C.id as iddoc
	,'I' as LNG
	,C.Protocollo 
	, convert( varchar , C.DataInvio , 103 ) as DataInvio


from
	ctl_doc C 

where C.tipodoc='SUB_QUESTIONARIO_FABBISOGNI' and C.Deleted=0



GO
