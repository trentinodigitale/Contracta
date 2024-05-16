USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_ART_36_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[OLD_PDA_ART_36_DOCUMENT_VIEW] AS

	select
		 idrow
		,idHeader
		,Allegato
		,AllegatoRisposta
		,dbo.GetPos(Descrizione, '-', 2) as DescrizioneCriterio -- Ottengo il nome Completo dell'allegato
		--,SUBSTRING(Descrizione, 3, LEN(Descrizione)) as Descrizione -- Ottengo il nome Completo dell'allegato
		,case 
			when dbo.GetPos(Descrizione, '-', 1) = 'T' then 'Busta Tecnica'
			when dbo.GetPos(Descrizione, '-', 1) = 'E' then 'Busta Economica'
			when dbo.GetPos(Descrizione, '-', 1) = 'A' then 'Busta Amministrativa'
			else ''
		 end as Tipo  -- Nel primo carattere della descrizione è stato cablato il tipo: T per tecnica e E per economica, A per Amministrativa
		from 
			CTL_DOC_ALLEGATI with(nolock)

	--select 
	--	Doc.*
	--	from 
	--		CTL_DOC d

	--		--salgo con il suo linked sulla PDA riga
	--		left join Document_microlotti_dettagli l with(nolock) on l.id = d.linkeddoc
	--		--idheader Document_microlotti_dettagli salgo sulla pda offerte
	--		left join document_pda_offerte O with(nolock) on O.idrow = l.idheader
	--		-- salgo sull'offerta con idmsg
	--		left join CTL_DOC Offer with(nolock) on Offer.id = O.idMsg
	--		--Recupero allegati offerta
	--		left join VIEW_CTL_DOC_ALLEGATI Doc with(nolock) on Doc.idheader = Offer.id

GO
