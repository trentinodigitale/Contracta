USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_BANDO_FABBISOGNI_USER_MANCANTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_MAIL_BANDO_FABBISOGNI_USER_MANCANTE] as

select 
	 CD.idrow as iddoc
	,'I' as LNG
	,C.Protocollo 
	, convert( varchar , C.DataInvio , 103 ) as DataInvio
	,C.body as Oggetto
	, convert( varchar , D.DataRiferimentoFine , 103 ) + ' ' + convert( varchar , D.DataRiferimentoFine , 108 ) as DataScadenza
	, convert( varchar , D.DataRiferimentoInizio , 103 ) + ' ' + convert( varchar , D.DataRiferimentoInizio , 108 ) as Datainizio
	, convert( varchar , D.DataPresentazioneRisposte , 103 ) + ' ' + convert( varchar , D.DataPresentazioneRisposte , 108 ) as DataFine
	, A.aziRagioneSociale as ente

from
	CTL_DOC_Destinatari CD
	inner join Ctl_doc C on C.id=CD.idHeader and C.TipoDoc='BANDO_FABBISOGNI'
	inner join Document_Bando D on D.idHeader=C.id
	inner join Aziende A on A.IdAzi=CD.IdAzi
where C.Deleted=0
GO
