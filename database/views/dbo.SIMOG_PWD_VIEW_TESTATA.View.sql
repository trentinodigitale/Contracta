USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SIMOG_PWD_VIEW_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SIMOG_PWD_VIEW_TESTATA] AS
	select [Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], 
			[StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], 
			[LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], 
			'' as [JumpCheck], 
			[StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]
			from ctl_doc with(nolock)

GO
