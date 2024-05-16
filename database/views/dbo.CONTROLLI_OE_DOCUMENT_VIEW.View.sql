USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONTROLLI_OE_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CONTROLLI_OE_DOCUMENT_VIEW] as
select
	[Id], [IdPfu], [IdDoc], [TipoDoc], 
	[Data], [Protocollo], [PrevDoc], [Deleted], 
	[Titolo], [Body], [Azienda], [StrutturaAziendale], 
	[DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale],
	[Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], 
	[SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], 
	[Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], 
	[Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], 
	[URL_CLIENT], [Caption], [FascicoloGenerale]
	 , DataDocumento
	 , case when StatoDoc='Saved' then '' else StatoDoc end as Statodoc
	  
	  

	from CTL_DOC with(nolock)	
		where TipoDoc='CONTROLLI_OE'
GO
