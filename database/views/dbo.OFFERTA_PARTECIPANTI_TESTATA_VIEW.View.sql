USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_PARTECIPANTI_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OFFERTA_PARTECIPANTI_TESTATA_VIEW] as
select 
	[Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], 
	[Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], 
	[Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], 
	[JumpCheck], [StatoFunzionale], [Destinatario_User], 
	[Destinatario_Azi] as fornitore, 
	[RichiestaFirma], 
	[NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], 
	[CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale], [CRYPT_VER]
	from ctl_doc
GO
