USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONVENZIONE_MOVE_LOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CONVENZIONE_MOVE_LOTTI_VIEW] as
select 
		Id, 
		IdPfu, 
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
		VersioneLinkedDoc, 
		GUID, 
		idPfuInCharge, 
		CanaleNotifica, 
		URL_CLIENT, 
		Caption,
		--se è stata creata una nuova convenzione ritorna il suo id
		case when ISNULL(c2.value,'')=1 and  ISNULL(c1.value,0) <> 0 then c1.value else 0 end as new_convenzione ,
		--se è stata creata una nuova integrazione ritorna il suo id
		case when ISNULL(c2.value,'') <> 1 and  ISNULL(c1.value,0) <> 0 then c1.value else 0 end as new_integrazione 
from ctl_doc
	left join ctl_doc_value C1 on C1.DSE_ID='TESTATA' and id=C1.idheader and C1.dzt_name='id_doc_trasferimentolotto'
	left join ctl_doc_value C2 on C2.DSE_ID='TESTATA' and id=C2.idheader and C2.dzt_name='Nuova_Convenzione'	
where tipodoc='CONVENZIONE_MOVE_LOTTI'
GO
