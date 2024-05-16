USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_CONVENZIONE_MOVE_LOTTI_DOCUMENT]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_VIEW_CONVENZIONE_MOVE_LOTTI_DOCUMENT] 
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
	,DC.TipoConvenzione
	,DC.ConAccessori
	,case when ISNULL(c2.idpfu,'') = C.idpfu then 'SI' else 'NO' end as APRI_DOCUMENTO
	,ISNULL(C2.id,0) as Id_Doc_New
	from ctl_doc C
		 	inner join document_convenzione DC on C.linkeddoc=DC.id
			inner join ctl_doc CC on DC.id=CC.id	
			left join ctl_doc_value CV on CV.dse_id='INFO_AGGIUNTIVE' and CV.DZT_Name='Id_doc_Trasferimento_Lotto' and Value=C.id
			left join ctl_doc C2 on C2.id=CV.IdHeader and C2.tipodoc='CONVENZIONE'
	where C.tipodoc like ('CONVENZIONE%')


GO
