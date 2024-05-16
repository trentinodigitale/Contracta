USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SCRITTURA_PRIVATA_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_SCRITTURA_PRIVATA_DOCUMENT_VIEW] as 
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
	   c1.value as DataRiferimento,
	   c2.value as DataRiferimentoInizio,
	   c3.value as DataRisposta,
	   c4.value as DataScadenzaOfferta,
	   c5.value as ProtocolloOfferta,
	   ISNULL(cs.F1_SIGN_HASH,'') as F1_SIGN_HASH,
	   ISNULL(cs.F1_SIGN_LOCK,'') as F1_SIGN_LOCK,
	   ISNULL(cs.F1_SIGN_ATTACH,'') as  F1_SIGN_ATTACH,
	   ISNULL(cs.F2_SIGN_ATTACH,'') as  F2_SIGN_ATTACH,
	   ISNULL(cs.F2_SIGN_HASH,'') as F2_SIGN_HASH,

	   c6.value as CodiceIPA,
	   c7.value as firmatario,

	   ' CodiceIPA , firmatario ' as NotEditable,
	   case 
			when isnull(c8.Value,'') = '' then 'no'
			else 'si'
		end as FlagScadenza
from 
	ctl_doc
	inner join ctl_doc_value c1 on c1.idheader=id and c1.DSE_ID='DOCUMENT' and c1.dzt_name='DataBando' and c1.row=0
	inner join ctl_doc_value c2 on c2.idheader=id and c2.DSE_ID='DOCUMENT' and c2.dzt_name='DataRiferimentoInizio' and c2.row=0
	inner join ctl_doc_value c3 on c3.idheader=id and c3.DSE_ID='DOCUMENT' and c3.dzt_name='DataRisposta' and c3.row=0
	inner join ctl_doc_value c4 on c4.idheader=id and c4.DSE_ID='DOCUMENT' and c4.dzt_name='DataScadenzaOfferta' and c4.row=0
	inner join ctl_doc_value c5 on c5.idheader=id and c5.DSE_ID='DOCUMENT' and c5.dzt_name='ProtocolloOfferta' and c5.row=0
	left join ctl_doc_sign cs on cs.idheader=id 

	left join ctl_doc_value c6 on c6.idheader=id and c6.DSE_ID='CONTRATTO' and c6.dzt_name='CodiceIPA' 
	left join ctl_doc_value c7 on c7.idheader=id and c7.DSE_ID='CONTRATTO' and c7.dzt_name='firmatario' 

	left join CTL_DOC_Value c8 on c8.IdHeader = Id and c8.DSE_ID ='CONTRATTO' and c8.dzt_name='DataScadenza' 

	where tipodoc='SCRITTURA_PRIVATA' and deleted=0
GO
