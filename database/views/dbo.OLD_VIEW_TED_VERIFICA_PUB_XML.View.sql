USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_TED_VERIFICA_PUB_XML]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- la vista è invocata per recuperare i dati utili alla verifica pubblicazione formulatorio ( sia per la richiesta di pubblicazione gara che per la rettifica ) 
CREATE VIEW [dbo].[OLD_VIEW_TED_VERIFICA_PUB_XML] AS
	select a.LinkedDoc as idBando, --chiave di ingresso
			g.TED_PUB_NO_DOC_EXT
		from CTL_DOC a with(nolock) 
				inner join Document_TED_GARA g with(nolock) on g.idHeader = a.id
		where a.StatoFunzionale = 'InAttesaPubTed' and g.TED_PUB_NO_DOC_EXT <> '' --deve ritornare sempre 1 solo record
		--where a.tipodoc = 'PUBBLICA_GARA_TED' and a.StatoFunzionale <> 'Annullato'
GO
