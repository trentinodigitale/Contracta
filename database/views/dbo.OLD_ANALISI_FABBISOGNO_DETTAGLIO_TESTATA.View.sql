USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ANALISI_FABBISOGNO_DETTAGLIO_TESTATA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[OLD_ANALISI_FABBISOGNO_DETTAGLIO_TESTATA] as 

	select 
		b.* 
		, d.Azienda 
		, d.richiestafirma
		, d.Body
		, m.id
		, a.idPfuInCharge
		, a.StatoFunzionale
		, d.Protocollo as protocolloriferimento
		, d.DataInvio as dataoperazione

	from Document_MicroLotti_Dettagli m -- riga di analisi
		inner join CTL_DOC a on a.id = m.IdHeader -- documento di analisi
		inner join CTL_DOC d on a.linkeddoc = d.id and d.deleted=0 -- bando
		inner join Document_Bando b on d.id = b.idheader -- dettagli del bando

	where d.tipodoc='BANDO_FABBISOGNI' 


GO
