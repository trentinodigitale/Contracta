USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_FABBISOGNI_IA_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_BANDO_FABBISOGNI_IA_DOCUMENT_VIEW] as
	Select 
	CD.idrow as id,
	C.id as VersioneLinkedDoc,
	ISNULL(CD.idpfu,0) as IdpfuinCharge,
    C.IdPfu,
	IdDoc, 
	TipoDoc, 
	StatoDoc, 
	Data, 
	Protocollo, 
	PrevDoc, 
	Deleted, 
	Titolo, 
	Body, 
	Azienda, 
	StrutturaAziendale, 
	DataInvio, 
	DataScadenza, 
	ProtocolloRiferimento, 
	ProtocolloGenerale, 
	Fascicolo, 
	Note, 
	DataProtocolloGenerale, 
	LinkedDoc, 
	SIGN_HASH, 
	SIGN_ATTACH, 
	SIGN_LOCK, 
	JumpCheck, 
	StatoFunzionale, 
	Destinatario_User, 
	Destinatario_Azi, 
	RichiestaFirma, 
	NumeroDocumento, 
	DataDocumento, 
	Versione, 
	GUID, 
	CanaleNotifica, 
	URL_CLIENT, 
	Caption, 
	FascicoloGenerale,
	cd.Id_Doc as Id_Doc_New , 
	TipoBando

from CTL_DOC_Destinatari CD
	inner join ctl_doc C on C.id=CD.idheader --and C.TipoDoc='BANDO_FABBISOGNI'
	inner join Document_Bando B on B.idheader = C.id



GO
