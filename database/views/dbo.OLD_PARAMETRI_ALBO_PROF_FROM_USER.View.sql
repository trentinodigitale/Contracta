USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PARAMETRI_ALBO_PROF_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_PARAMETRI_ALBO_PROF_FROM_USER]
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
	scelta_classi_libera
from profiliutente u
inner join Document_Parametri_Abilitazioni p on p.TipoDoc = 'ALBO_PROF' and p.deleted = 0
left outer join CTL_DOC d on d.tipodoc = 'PARAMETRI_ALBO_PROF' and d.deleted = 0 and d.StatoFunzionale = 'Confermato' 

GO
