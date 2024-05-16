USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_ART_36_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[PDA_ART_36_TESTATA_VIEW] as

	select
		 d.id
		,d.Idpfu
		,d.DataInvio
		,d.StatoFunzionale
		,d.Azienda
		,azi.aziRagioneSociale
		,d.Protocollo
		,l.NumeroLotto
		,OFFER.Protocollo as ProtocolloRiferimento

		from CTL_DOC d with (nolock)
				inner join Aziende azi with(nolock) on azi.IdAzi = d.Azienda
				inner join Document_MicroLotti_Dettagli l with (nolock) on l.id = d.LinkedDoc
				left join document_pda_offerte O with (nolock) on O.idrow=l.idheader
				left join ctl_doc OFFER with (nolock) on OFFER.id=O.IdMsgFornitore

GO
