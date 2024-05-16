USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CONVENZIONE_PROROGA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[VIEW_CONVENZIONE_PROROGA] 
AS
SELECT 
	C.Id, 
	C.IdPfu, C.IdDoc, C.TipoDoc, C.StatoDoc, C.Data, C.Protocollo, C.PrevDoc, C.Deleted, 
	C.Titolo, C.Body, C.Azienda, C.StrutturaAziendale, C.DataInvio, C.DataScadenza, C.ProtocolloRiferimento, 
	C.Fascicolo, C.Note,  C.LinkedDoc, C.SIGN_HASH, 
	C.SIGN_ATTACH, C.SIGN_LOCK, C.JumpCheck, C.StatoFunzionale, C.Destinatario_User, C.Destinatario_Azi, 
	C.RichiestaFirma, C.NumeroDocumento, C.DataDocumento, C.Versione, C.VersioneLinkedDoc, C.GUID, C.idPfuInCharge, C.CanaleNotifica, C.URL_CLIENT, 
	C.Caption
	,DC.NumOrd
	,CC.ProtocolloGenerale
	,CC.DataProtocolloGenerale
	,DC.DataFine
	from ctl_doc C
		 	inner join document_convenzione DC on C.linkeddoc=DC.id
				inner join ctl_doc CC on DC.id=CC.id	
	where C.tipodoc='CONVENZIONE_PROROGA'
GO
