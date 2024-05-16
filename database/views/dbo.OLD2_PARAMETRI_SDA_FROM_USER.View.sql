USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PARAMETRI_SDA_FROM_USER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_PARAMETRI_SDA_FROM_USER]
as

select 
		idpfu as ID_FROM, 
		NumMesiScadenza, 
		Sollecito, 
		NumPeriodiFreqPrimaria, 
		FreqPrimaria, 
		FreqSecondaria, 
		NumMaxPerConferma, 
		TipoDoc, 
		Note, 
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
		[Conferma_Gestore]

from profiliutente
	inner join Document_Parametri_Abilitazioni on TipoDoc = 'SDA' and deleted = 0


GO
