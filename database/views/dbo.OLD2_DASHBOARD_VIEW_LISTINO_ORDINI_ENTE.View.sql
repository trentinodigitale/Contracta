USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_LISTINO_ORDINI_ENTE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_LISTINO_ORDINI_ENTE] as

--visibilità al compilatore della convenzione
Select
	
	CV.idpfu as DOC_OWNER,
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
	 --left join profiliutente P with (nolock) on P.pfuIdAzi = C.Destinatario_Azi
	 inner join Document_Convenzione DC with (nolock) on DC.ID=CV.id
	 
	where c.deleted=0 
		  and c.tipodoc in ('LISTINO_ORDINI_OE')
		  --and c.StatoFunzionale <> 'InLavorazione'

union

--visibilità ai referenti tecnici della convezione
Select
	
	DR.idpfu as DOC_OWNER,
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
	 inner join Document_Bando_Riferimenti DR with (nolock) on DR.idHeader = CV.id and DR.RuoloRiferimenti='ReferenteTecnico'
	where c.deleted=0 
		  and c.tipodoc in ('LISTINO_ORDINI_OE')
		 
GO
