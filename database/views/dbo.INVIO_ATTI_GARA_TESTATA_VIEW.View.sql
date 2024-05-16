USE [AFLink_TND]
GO
/****** Object:  View [dbo].[INVIO_ATTI_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[INVIO_ATTI_GARA_TESTATA_VIEW]
AS
SELECT     
	C.[Id], C.[IdPfu], C.[IdDoc], C.[TipoDoc], C.[StatoDoc], C.[Data], C.[Protocollo], C.[PrevDoc], C.[Deleted], C.[Titolo], C.[Body],  C.[StrutturaAziendale], C.[DataInvio], C.[DataScadenza], C.[ProtocolloRiferimento], C.[ProtocolloGenerale], C.[Fascicolo], C.[Note], C.[DataProtocolloGenerale], C.[LinkedDoc], C.[SIGN_HASH], C.[SIGN_ATTACH], C.[SIGN_LOCK], C.[JumpCheck], C.[StatoFunzionale], C.[Destinatario_User],  C.[RichiestaFirma], C.[NumeroDocumento], C.[DataDocumento], C.[Versione], C.[VersioneLinkedDoc], C.[GUID], C.[idPfuInCharge], C.[CanaleNotifica], C.[URL_CLIENT], C.[Caption], C.[FascicoloGenerale],
	Document_Richiesta_Atti.*,
	PENTE.pfuidazi as [Azienda],
	FORN.pfuIdAzi as [Destinatario_Azi]
	FROM dbo.CTL_DOC C with(nolock)
	LEFT OUTER JOIN dbo.Document_Richiesta_Atti  with(nolock) ON C.Id = dbo.Document_Richiesta_Atti.idHeader
	inner join ProfiliUtente PENTE with(nolock)  on PENTE.idpfu=C.idpfu
	inner join CTL_DOC RICHIESTA with(nolock) on RICHIESTA.id=C.linkeddoc
	inner join ProfiliUtente FORN with(nolock)  on FORN.idpfu=RICHIESTA.idpfu
where C.TipoDoc='INVIO_ATTI_GARA'
GO
