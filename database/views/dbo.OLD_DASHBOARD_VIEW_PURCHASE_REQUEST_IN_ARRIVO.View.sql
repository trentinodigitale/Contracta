USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PURCHASE_REQUEST_IN_ARRIVO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_PURCHASE_REQUEST_IN_ARRIVO] AS
	select [Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID],  [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale], [CRYPT_VER]
			, isnull([idPfuInCharge],0) as idPfuInCharge,
				b.Applicant,
				a.Azienda as AZI_Ente
				
		from ctl_doc a with(nolock)
				inner join document_pr b with(nolock) on b.idheader = a.id
		where a.TipoDoc = 'PURCHASE_REQUEST' AND a.Deleted = 0 
			--and a.StatoFunzionale = 'Ricevuto'
GO
