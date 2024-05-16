USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARAMETRI_CONVENZIONE_TESTATA_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[PARAMETRI_CONVENZIONE_TESTATA_FROM_USER] as
select
	p.idpfu as ID_FROM,
	D.[Id], 
	D.[IdPfu], 
	D.[IdDoc], 
	D.[TipoDoc], 
	D.[StatoDoc], 
	D.[Data], 
	D.[PrevDoc], 
	D.[Deleted], 
	D.[Titolo], 
	D.[Body], 
	D.[Azienda], 
	D.[StrutturaAziendale], 
	D.[DataScadenza], 
	D.[ProtocolloRiferimento], 
	D.[ProtocolloGenerale], 
	D.[Fascicolo], 
	D.[Note], 
	D.[DataProtocolloGenerale], 
	D.[LinkedDoc], 
	D.[SIGN_HASH], 
	D.[SIGN_ATTACH], 
	D.[SIGN_LOCK], 
	D.[JumpCheck], 
	[Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], 
	[Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], 
	[Caption], [FascicoloGenerale], [CRYPT_VER], [Attiva_Chiusura_Auto], [FreqPrimaria], 
	[FreqSecondaria], [NumGiorni], [NumPeriodiFreqPrimaria], [Sollecito]
	
	
from 
PARAMETRI_CONVENZIONE_TESTATA_VIEW	D
	cross join profiliUtente p
where  
	tipodoc='parametri_convenzione' 
	and statofunzionale='confermato'
GO
