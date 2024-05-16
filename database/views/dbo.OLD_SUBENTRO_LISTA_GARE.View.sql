USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SUBENTRO_LISTA_GARE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_SUBENTRO_LISTA_GARE] as

	select a.id as idheader ,
		   	b.value as NomeDocumento,
			c.value as Protocollo,
			d.value as Fascicolo,
			e.value as DataInvio,
			f.value as Titolo,
			b.row
		
		from ctl_doc a with(nolock)
				inner join ctl_doc_value b with(nolock) on b.IdHeader = a.id and b.DSE_ID = 'LISTA' and b.DZT_Name = 'NomeDocumento'
				inner join ctl_doc_value c with(nolock)  on c.IdHeader = a.id and c.row = b.row and c.DSE_ID = 'LISTA' and c.DZT_Name = 'Protocollo'
				inner join ctl_doc_value d with(nolock)  on d.IdHeader = a.id and d.row = b.row and d.DSE_ID = 'LISTA' and d.DZT_Name = 'Fascicolo'
				inner join ctl_doc_value e with(nolock)  on e.IdHeader = a.id and e.row = b.row and e.DSE_ID = 'LISTA' and e.DZT_Name = 'DataInvio'
				inner join ctl_doc_value f with(nolock)  on f.IdHeader = a.id and f.row = b.row and f.DSE_ID = 'LISTA' and f.DZT_Name = 'Titolo'

		where a.tipodoc = 'SUBENTRO'
		

GO
