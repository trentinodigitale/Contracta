USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_DOCUMENT_CARRELLO_ME]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_VIEW_DOCUMENT_CARRELLO_ME] as 

select	C.[id], [Marca], [Linea], [Modello], [Codice], [Categoria], c.Descrizione, [Nota], [QtMin], [QTDisp], [Composizione], [Fascia], c.PrezzoUnitario, [Foto], [Colore], c.deleted, c.idPfu, [QtaXconf], [NumConf], [Plant], [Id_Catalogo], [Fornitore], [Id_Product], [TipoOrdine], [ImportoCompenso], [UnitMis], [Immagine], [Brochure], [TipoProdotto], [ToDelete], [RicPreventivo],[Importo_Residuo_Quote], [Iva], c.Titolo,  [Not_Editable] 
		, D.UnitadiMisura
		, ca.azienda as Mandataria 
		, case 
				when i.StatoIscrizione = 'Iscritto' and ca.StatoFunzionale = 'Pubblicato' then ''
				when ca.StatoFunzionale <> 'Pubblicato' then 'Catalogo non pubblicato'
				when i.StatoIscrizione <> 'Iscritto' then 'il fornitore è sospeso dall''albo'
				else C.EsitoRiga --'Articolo non più disponibile'
			
			end as EsitoRiga

	from carrello_ME C with(nolock ) 

		-- prodotto del catalogo
		inner join		document_microlotti_dettagli D with(nolock )  on C.Id_Product=D.id

		-- catalogo
		inner join CTL_DOC ca with(nolock )  on D.idheader= ca.id

		-- iscrizione all'albo
		inner join ctl_doc_destinatari i with(nolock) on i.idheader = ca.linkeddoc and i.idazi = ca.azienda




GO
