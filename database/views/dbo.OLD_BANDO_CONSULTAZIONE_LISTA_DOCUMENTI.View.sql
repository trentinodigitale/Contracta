USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_CONSULTAZIONE_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_BANDO_CONSULTAZIONE_LISTA_DOCUMENTI] as

	select 
		--c.*
		 [Id], [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], 
		 [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], 
		 [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], 
		 [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], 
		 [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], 
		 [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], 
		 [URL_CLIENT], [Caption], [FascicoloGenerale], [CRYPT_VER]
		
		, tipodoc as OPEN_DOC_NAME
	
	from ctl_doc c with (nolock)
	where deleted = 0
		and TipoDoc in ('RETTIFICA_CONSULTAZIONE','PROROGA_CONSULTAZIONE','PDA_COMUNICAZIONE_GENERICA')
		and StatoFunzionale<>'Annullato'
		and deleted=0

	union all

	--le comunicazioni associate alle risposte al bando consultazione
	select 
		COM.[Id], COM.[IdPfu], COM.[IdDoc], COM.[TipoDoc], COM.[StatoDoc], COM.[Data], COM.[Protocollo], 
		COM.[PrevDoc], COM.[Deleted], COM.[Titolo], COM.[Body], COM.[Azienda], COM.[StrutturaAziendale], 
		COM.[DataInvio], COM.[DataScadenza], COM.[ProtocolloRiferimento], COM.[ProtocolloGenerale], COM.[Fascicolo], 
		COM.[Note], COM.[DataProtocolloGenerale], CR.[LinkedDoc], COM.[SIGN_HASH], COM.[SIGN_ATTACH],COM.[SIGN_LOCK], 
		COM.[JumpCheck], COM.[StatoFunzionale], COM.[Destinatario_User], COM.[Destinatario_Azi], COM.[RichiestaFirma], 
		COM.[NumeroDocumento], COM.[DataDocumento], COM.[Versione], COM.[VersioneLinkedDoc], COM.[GUID], 
		COM.[idPfuInCharge], COM.[CanaleNotifica], COM.[URL_CLIENT], COM.[Caption], COM.[FascicoloGenerale], 
		COM.[CRYPT_VER]

		, COM.tipodoc as OPEN_DOC_NAME
		
		from ctl_doc COM with (nolock)
			inner join ctl_doc CR with (nolock) on CR.id=COM.LinkedDoc and cr.tipodoc='RISPOSTA_CONSULTAZIONE'
			inner join  ctl_doc B with (nolock) on B.id=CR.LinkedDoc and B.tipodoc='BANDO_CONSULTAZIONE'
	where COM.deleted = 0
		and COM.TipoDoc in ('PDA_COMUNICAZIONE_GARA')
		and COM.JumpCheck like '%BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA'
		and COM.StatoFunzionale not in ('InLavorazione','Annullato')
		and COM.deleted=0
GO
