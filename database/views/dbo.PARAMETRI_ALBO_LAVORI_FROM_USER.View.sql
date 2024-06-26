USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARAMETRI_ALBO_LAVORI_FROM_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[PARAMETRI_ALBO_LAVORI_FROM_USER]
as

select 
	u.idpfu as ID_FROM
	,d.SIGN_ATTACH ,  
	NumMesiScadenza,
	Sollecito, 
	NumPeriodiFreqPrimaria, 
	FreqPrimaria,
	FreqSecondaria, 
	NumMaxPerConferma, 
	p.TipoDoc, 
	p.Note, 
	TestoAmmessa, 
	TestoRigetto, 
	TestoIntegrativa, 
	OggettoAmmessa, 
	OggettoIntegrativa, 
	OggettoRigetto,
	d.SIGN_HASH,
	ISNULL(p.Attiva_Sospensione,1) as Attiva_Sospensione,
	N_DocInSeduta,
	Attiva_Mail_Riferimenti_conf_automatica,
	p.Attiva_vincolo_firma_digitale_sedute_valutazione,
	Scelta_Classi_Libera,
	Sospendi_Su_NuovaIstanza

from 
	profiliutente u with (nolock)
		inner join Document_Parametri_Abilitazioni p with (nolock) on p.TipoDoc = 'ALBO_LAVORI' and p.deleted = 0
		left outer join CTL_DOC d with (nolock) on d.tipodoc = 'PARAMETRI_ALBO_LAVORI' and d.deleted = 0 and d.StatoFunzionale = 'Confermato' 
GO
