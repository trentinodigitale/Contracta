USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARAMETRI_SDA_FROM_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[PARAMETRI_SDA_FROM_USER]
as

select 
		U.idpfu as ID_FROM, 
		NumMesiScadenza, 
		Sollecito, 
		NumPeriodiFreqPrimaria, 
		FreqPrimaria, 
		FreqSecondaria, 
		NumMaxPerConferma, 
		A.TipoDoc, 
		A.Note, 
		TestoAmmessa, 
		TestoRigetto, 
		TestoIntegrativa, 
		OggettoAmmessa, 
		OggettoIntegrativa, 
		OggettoRigetto,
		ISNULL(Attiva_Sospensione,1) as Attiva_Sospensione,
		N_DocInSeduta,
		Attiva_Mail_Riferimenti_conf_automatica,
		[FreqControlli], 
		[Tipo_Estrazione], 
		[Perc_Soggetti], 
		[Num_estrazione_mista], 
		[elenco_documenti_controlli_OE], 
		[Conferma_Gestore],
	    Attiva_vincolo_firma_digitale_sedute_valutazione,
		Sospendi_Su_NuovaIstanza
from 
	profiliutente U with (nolock)
		inner join Document_Parametri_Abilitazioni A with (nolock) on A.TipoDoc = 'SDA' and A.deleted = 0
		inner join ctl_doc P with (nolock)  on P.id= A.idheader
where 
	P.tipodoc='PARAMETRI_SDA' and p.statofunzionale = 'confermato' and p.Deleted =0

GO
