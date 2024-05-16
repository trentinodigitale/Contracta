USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_BANDO_FABBISOGNI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_MAIL_BANDO_FABBISOGNI] as

select 
	 C.id as iddoc
	,'I' as LNG
	,C.Protocollo 
	, convert( varchar , C.DataInvio , 103 ) as DataInvio
	,C.body as Oggetto
	, convert( varchar , D.DataPresentazioneRisposte , 103 ) + ' ' + convert( varchar , D.DataPresentazioneRisposte , 108 ) as DataScadenza
	, convert( varchar , D.DataRiferimentoInizio , 103 ) + ' ' + convert( varchar , D.DataRiferimentoInizio , 108 ) as Datainizio
	, convert( varchar , D.DataRiferimentoFine , 103 ) + ' ' + convert( varchar , D.DataRiferimentoFine , 108 ) as DataFine


from
	ctl_doc C 
	inner join Document_Bando D on D.idHeader=C.id
	--where C.tipodoc='BANDO_FABBISOGNI' and C.Deleted=0







GO
