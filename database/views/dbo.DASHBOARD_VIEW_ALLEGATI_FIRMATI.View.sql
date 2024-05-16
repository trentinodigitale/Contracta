USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ALLEGATI_FIRMATI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_ALLEGATI_FIRMATI] as 
select  
	CTL_DOC_SIGN.idRow, 
	idHeader, 
	F1_DESC, 
	F1_SIGN_HASH, 
	F1_SIGN_ATTACH, 
	F1_SIGN_LOCK, 
	F2_DESC, 
	F2_SIGN_HASH, 
	F2_SIGN_ATTACH, 
	F2_SIGN_LOCK, 
	F3_DESC, 
	F3_SIGN_HASH, 
	F3_SIGN_ATTACH, 
	F3_SIGN_LOCK, 
	F4_DESC, 
	F4_SIGN_HASH, 
	F4_SIGN_ATTACH, 
	F4_SIGN_LOCK,
	C.protocollogenerale,
	C.Dataprotocollogenerale,
	ISNULL(DC.NotEditable,'') as NotEditable
from CTL_DOC_SIGN  with(nolock) 
left join CTL_DOC C   with(nolock) on CTL_DOC_SIGN.idHeader=C.id and C.tipodoc='CONVENZIONE'
left join Document_Convenzione DC   with(nolock) on c.id=dc.id 




GO
