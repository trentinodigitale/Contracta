USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PRODOTTI_CATALOGO_MEA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--use AFLink_PA_Dev

CREATE view [dbo].[DASHBOARD_VIEW_PRODOTTI_CATALOGO_MEA] as


--------

----AliquotaIva
----AREA_DI_CONSEGNA 
----ClasseIscriz
----Descrizione
----PREZZO_OFFERTO_PER_UM
----UnitadiMisura

--(Vedi PPT per esempio di rappresentazione)

--Categorie , Area di  Consegna
--Fornitore
--Codice, Descrizione
--Descrizione Estesa
--Prezzo DA , Prezzo A


--Griglia
------------
--Seleziona ( Check )
--Aggiungi 
--Scheda
--Info
--Immagine
--Descrizione
--Fornitore
--Prezzo
--Iva


select 

	P.id 
	, p.ALL_FIELD
	,p.AliquotaIva
	,p.AREA_DI_CONSEGNA 
	,p.ClasseIscriz_S -- Categorie
	,p.Descrizione
	,p.PREZZO_OFFERTO_PER_UM
	,p.UnitadiMisura
	,P.FotoProdotto
	,s.aziRagioneSociale
	, s.IdAzi as idAzi2
	, s.IdAzi as Mandataria
	, p.PREZZO_OFFERTO_PER_UM as RangeDa
	, p.PREZZO_OFFERTO_PER_UM as RangeA
	, P.CodiceProdotto

	, '<img class="img_label_alt" alt="Foto prodotto" height="80px"
		src="../CTL_Library/functions/field/DisplayAttach.ASP?OPERATION=DISPLAY&TECHVALUE=' + dbo.HTML_Encode( P.FotoProdotto ) + ' 
		title="" 
		aria-describedby="GridViewer_Oggetto">' as oggetto

	, 1 as QTDisp

	--, s.StatoIscrizione
	, '' as Not_Editable


	from CTL_DOC C with(nolock)  -- tutti i cataloghi MEA
		
		---- collegati ad albi publicati
		inner join CTL_DOC A with(nolock) on C.linkedDoc = A.id and A.statofunzionale = 'Pubblicato'

		---- dove il fornitore risulta iscritto
		inner  join CTL_DOC_Destinatari s with( nolock ) on s.idHeader = A.Id and s.IdAzi = C.Azienda  and s.StatoIscrizione = 'Iscritto'

		-- prodotti del catalogo
		inner  join Document_MicroLotti_Dettagli P with(nolock) on P.IdHeader = C.Id and P.TipoDoc = C.TipoDoc


	where 
		C.TipoDoc = 'CATALOGO_MEA'
		and C.deleted = 0
		and C.StatoFunzionale = 'Pubblicato'
GO
