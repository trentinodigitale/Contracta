USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_SDA_ALLEGATI_RETTIFICA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[BANDO_SDA_ALLEGATI_RETTIFICA_VIEW] as

select
	c.id as IDHeader,
	ca1.IdRow,
	ca1.Descrizione,
	ca1.Allegato
from 
ctl_doc c
	left join ctl_doc c2 on c2.linkedDoc=c.id and  c2.tipodoc in ( 'PROROGA_BANDO','RETTIFICA_BANDO')  
	left join ctl_doc_allegati ca1 on ca1.idheader=c2.id
where c.tipodoc in ('BANDO','BANDO_SDA') and c.StatoFunzionale <> 'InLavorazione'
	  and ISNULL(ca1.Descrizione,'')<>'' and ISNULL(ca1.Allegato,'')<>'' and c2.Statofunzionale='Approved'





GO
