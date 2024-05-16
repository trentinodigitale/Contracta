USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_GARA_ALLEGATI_RETTIFICA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD_BANDO_GARA_ALLEGATI_RETTIFICA_VIEW] as

select
	c.id as IDHeader,
	ca1.IdRow,
	ca1.Descrizione,
	ca1.Allegato, 
	
	case 
		when c2.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' AND c2.JumpCheck='0-REVOCA_BANDO' then 	'REVOCA_GARA'
		when c2.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' AND c2.JumpCheck='0-SOSPENSIONE_GARA' then 	'SOSPENSIONE_GARA'
		else c2.TipoDoc 
	end as TipoDoc 

from 
	ctl_doc c with (nolock)
	left join ctl_doc c2  with (nolock) on c2.linkedDoc=c.id and ( c2.tipodoc in ( 'PROROGA_GARA','RETTIFICA_GARA' ,'RIPRISTINO_GARA')  or (c2.tipodoc='PDA_COMUNICAZIONE_GENERICA' and c2.jumpcheck in( '0-SOSPENSIONE_GARA','0-REVOCA_BANDO') ))
	left join ctl_doc_allegati ca1  with (nolock) on ca1.idheader=c2.id
where 
	c.tipodoc in ( 'BANDO_GARA','BANDO_SEMPLIFICATO', 'BANDO_CONCORSO' )  and c.StatoFunzionale <> 'InLavorazione'
	 and ISNULL(ca1.Descrizione,'')<>'' and ISNULL(ca1.Allegato,'')<>'' and c2.Statofunzionale='Inviato'



GO
