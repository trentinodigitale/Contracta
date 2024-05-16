USE [AFLink_TND]
GO
/****** Object:  View [dbo].[LISTATEMPLATE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--nuova vista per visualizzare la lista di template che è possibile creare per una PDA
---------------------------------------------------------------

CREATE VIEW [dbo].[LISTATEMPLATE]
as
select V1.*,isnull(V2.NumeroVerbali,0) as NumeroVerbali from 
(
select C.*,V.*,T.idmsg as IdPDA from ctl_doc C,
    document_verbalegara V,
	tab_messaggi_fields  T
where 
    C.id=V.idheader and 
    C.tipodoc = 'VERBALETEMPLATE'
	and T.isubtype=169
	and c.deleted=0
	and statofunzionale='Pubblicato'
) V1 

left join 
(select c.linkeddoc  , v.IdTipoVerbale , count(*) as NumeroVerbali
from 
	ctl_doc C,		
	Document_VerbaleGara V 
where 
	C.id=V.idheader and
	C.tipodoc='VERBALEGARA' and
	C.StatoDoc<>'Annullato'
group by c.linkeddoc,v.IdTipoVerbale) V2

on V1.IdPDA=V2.linkeddoc and V1.id=V2.IdTipoVerbale

GO
