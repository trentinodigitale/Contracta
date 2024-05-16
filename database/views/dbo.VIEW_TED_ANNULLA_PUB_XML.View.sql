USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_ANNULLA_PUB_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_TED_ANNULLA_PUB_XML] AS
	select a.id, --chiave di ingresso
			g.TED_PUB_NO_DOC_EXT
		from CTL_DOC a with(nolock) 
				inner join Document_TED_GARA g with(nolock) on g.idHeader = a.id
		where a.tipodoc = 'ANNULLA_PUBBLICAZIONE_TED' and a.StatoFunzionale <> 'Annullato'
GO
