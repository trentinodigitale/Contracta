USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_SIGN_PREGARA_DETERMINA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CTL_DOC_SIGN_PREGARA_DETERMINA] as
select 
	[idRow], 
	[idHeader], 
	[F1_DESC], 
	[F1_SIGN_HASH], 
	[F1_SIGN_ATTACH], 
	[F1_SIGN_LOCK], 
	[F2_DESC], 
	[F2_SIGN_HASH], 
	[F2_SIGN_ATTACH], 
	[F2_SIGN_LOCK], 
	[F3_DESC], 
	[F3_SIGN_HASH], 
	[F3_SIGN_ATTACH], 
	[F3_SIGN_LOCK], 
	[F4_DESC], 
	[F4_SIGN_HASH], 
	[F4_SIGN_ATTACH], 
	[F4_SIGN_LOCK] ,  

	--F4_SIGN_LOCK = '1' allegato inserito dalla lista degli atti
	case when F4_SIGN_LOCK = '1' then ' F3_DESC ' else '' end +
		case 
			when CR0.REL_ValueOutput IS Not NULL then  CR0.REL_ValueOutput
			when CR1.REL_ValueOutput IS Not NULL then  CR1.REL_ValueOutput			 
			else '  '  
		end	
	AS NotEditable

	from CTL_DOC_SIGN CS with(nolock)
		inner join CTL_DOC C with(nolock) on CS.idHeader=C.Id and C.TipoDoc='PREGARA'
		left join CTL_Relations CR0 with(nolock) on CR0.REL_Type='DOCUMENT_PREGARA_NOT_EDITABLE_DETERMINA_For_Stato' and CR0.REL_ValueInput=C.StatoFunzionale
		left join CTL_Relations CR1 with(nolock) on CR1.REL_Type='DOCUMENT_PREGARA_NOT_EDITABLE_DETERMINA_For_Stato' and CR1.REL_ValueInput=C.StatoFunzionale
	where F4_DESC = 'DETERMINA'
GO
