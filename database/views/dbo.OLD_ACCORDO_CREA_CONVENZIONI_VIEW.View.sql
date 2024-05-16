USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ACCORDO_CREA_CONVENZIONI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_ACCORDO_CREA_CONVENZIONI_VIEW]
as

select 
	doc.Id as idHeader,
	doc.Azienda,
	doc.StatoFunzionale,
	a.Value as aziPartitaIVA,
	b.Value as aziRagioneSociale,
	c.Value as codicefiscale,
	d.Value as IdAzi,
	e.Value as Indirizzo

	from CTL_DOC as doc with(nolock)

		left join CTL_DOC_Value as a with(nolock) on doc.id = a.IdHeader and a.DSE_ID = 'ENTI' and a.DZT_Name = 'aziPartitaIVA'

		left join CTL_DOC_Value as b with(nolock) on doc.id = b.IdHeader and b.DSE_ID = 'ENTI' and b.DZT_Name = 'aziRagioneSociale' and b.Row = a.Row

		left join CTL_DOC_Value as c with(nolock) on doc.id = c.IdHeader and c.DSE_ID = 'ENTI' and c.DZT_Name = 'codicefiscale' and c.Row = b.Row

		left join CTL_DOC_Value as d with(nolock) on doc.id = d.IdHeader and d.DSE_ID = 'ENTI' and d.DZT_Name = 'IdAzi' and d.Row = c.Row

		left join CTL_DOC_Value as e with(nolock) on doc.id = e.IdHeader and e.DSE_ID = 'ENTI' and e.DZT_Name = 'Indirizzo' and e.Row = d.Row

	where doc.TipoDoc = 'ACCORDO_CREA_CONVENZIONI' and Deleted = 0

GO
