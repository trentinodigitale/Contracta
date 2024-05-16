USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_CONTRATTO_CONVENZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_CONTRATTO_CONVENZIONE] as
Select
	c.destinatario_user as DOC_OWNER,
	c.id,
	c.linkedDoc,
	C.StatoFunzionale,
	C.Protocollo,
	C.tipodoc as OPEN_DOC_NAME,
	C.DataInvio,
	C.Titolo as Name,
	CV.Titolo as DOC_Name
from ctl_doc c
	inner join ctl_doc CV on CV.id=c.linkeddoc and CV.Tipodoc='CONVENZIONE'
	where c.deleted=0 
		  and c.tipodoc='CONTRATTO_CONVENZIONE'
		  and c.StatoFunzionale <> 'InLavorazione'



GO
