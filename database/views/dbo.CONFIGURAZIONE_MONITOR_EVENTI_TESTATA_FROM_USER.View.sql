USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFIGURAZIONE_MONITOR_EVENTI_TESTATA_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[CONFIGURAZIONE_MONITOR_EVENTI_TESTATA_FROM_USER] as
select
	p.idpfu as ID_FROM,
	D.[Id], 
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
	[Caption], [FascicoloGenerale], [CRYPT_VER]
	
	
from 
CONFIGURAZIONE_MONITOR_EVENTI_TESTATA_VIEW	D
	cross join profiliUtente p
where  
	tipodoc='CONFIGURAZIONE_MONITOR_EVENTI' 
	and statofunzionale='confermato'
GO
