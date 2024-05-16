USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_VIEW_COMMISSIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CTL_DOC_VIEW_COMMISSIONE] as 

select 
	  Id, IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, 
	  DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, 
	  LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, 
	  Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, 
	  VersioneLinkedDoc, GUID
	  , ISNULL(idPfuInCharge,0) as idPfuInCharge
	  , CanaleNotifica
	  ,URL_CLIENT
	  ,Caption
	  , FascicoloGenerale
	  , c1.value as Conformita
	  , c2.value as CriterioAggiudicazioneGara
	from 
		ctl_doc c
			left join ctl_doc_value c1 on c1.IdHeader=id and c1.dse_id='TESTATA' and c1.DZT_Name='Conformita'
			left join ctl_doc_value c2 on c2.IdHeader=id and c2.dse_id='TESTATA' and c2.DZT_Name='CriterioAggiudicazioneGara'
		where tipodoc='COMMISSIONE_PDA'






GO
