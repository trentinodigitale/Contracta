USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_LISTINO_CONVENZIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[DASHBOARD_VIEW_LISTINO_CONVENZIONE] as
Select
	--c.destinatario_user as DOC_OWNER,
	case when ISNULL(C.idPfuInCharge,0)=0 then c.destinatario_user else C.idPfuInCharge end as DOC_OWNER,
	c.id,
	c.linkedDoc,
	C.StatoFunzionale,
	C.Protocollo,
	C.tipodoc as OPEN_DOC_NAME,
	C.DataInvio,
	C.Titolo as Name
	,CV.Titolo as DOC_Name
	,DC.NumOrd
	,case when ISNULL(CV.JumpCheck,'') = 'INTEGRAZIONE' then 'si' else 'no' end as Multiplo
from ctl_doc c with (nolock)
	 inner join ctl_doc CV with (nolock) on CV.id=c.linkeddoc and CV.Tipodoc='CONVENZIONE'
	 inner join Document_Convenzione DC with (nolock) on DC.ID=CV.id
	where c.deleted=0 
		  and c.tipodoc in ('LISTINO_CONVENZIONE')
		  and c.StatoFunzionale <> 'InLavorazione'
GO
