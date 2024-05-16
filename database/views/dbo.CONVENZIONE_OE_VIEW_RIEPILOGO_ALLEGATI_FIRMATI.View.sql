USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_OE_VIEW_RIEPILOGO_ALLEGATI_FIRMATI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[CONVENZIONE_OE_VIEW_RIEPILOGO_ALLEGATI_FIRMATI] as
select 
	c1.id as idHeader,
	c2.id as idRow,
	c2.ProtocolloGenerale,
	c2.DataProtocolloGenerale,
	c3.F1_SIGN_ATTACH,
	c3.F2_SIGN_ATTACH,
	c3.F3_SIGN_ATTACH

from ctl_doc c1
inner join ctl_doc c2 on c1.id=c2.linkedDoc and C2.tipodoc='CONVENZIONE' and ISNULL(c2.jumpcheck,'')='INTEGRAZIONE' and c2.Statofunzionale='Pubblicato'
inner join ctl_doc_sign c3 on c2.id=c3.idheader

union 


select 
	c1.id as idHeader,
	c1.id as idRow,
	c1.ProtocolloGenerale,
	c1.DataProtocolloGenerale,
	c3.F1_SIGN_ATTACH,
	c3.F2_SIGN_ATTACH,
	c3.F3_SIGN_ATTACH

from ctl_doc c1
inner join ctl_doc_sign c3 on c1.id=c3.idheader
where c1.tipodoc='CONVENZIONE' and ISNULL(c1.jumpcheck,'') <> 'INTEGRAZIONE' and c1.Statofunzionale='Pubblicato'
GO
