USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SCHEDA_PRODOTTO_DOCUMENT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[SCHEDA_PRODOTTO_DOCUMENT]
AS
SELECT  a.Id,      
		a.StatoRiga,
		b.DataInvio as DataPubblicazione,
		b.Azienda,
		b.idpfu,
		case when c.StatoIscrizione = 'Iscritto' then b.StatoFunzionale
			when c.StatoIscrizione <> 'Iscritto' and b.StatoFunzionale <> 'Publicato' then b.StatoFunzionale
			else 'Sospeso' 
			end as StatoFunzionale,
		'<img class="img_label_alt" alt="Foto prodotto" height="400px"
		src="../../CTL_Library/functions/field/DisplayAttach.ASP?OPERATION=DISPLAY&TECHVALUE=' + dbo.HTML_Encode( a.FotoProdotto ) + ' 
		title="">' as oggetto,		
		a.CodiceProdotto,
		a.Descrizione,
		a.IdHeader as LinkedDoc
FROM            
		Document_MicroLotti_Dettagli as a with (nolock)
		inner join CTL_DOC as b ON a.IdHeader = b.Id
		inner join CTL_DOC_Destinatari as c on b.LinkedDoc = c.idHeader and c.IdAzi = b.Azienda
	--	inner join aziende c with (nolock) on b.Azienda = c.IdAzi
GO
