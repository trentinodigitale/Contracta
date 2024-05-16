USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_GUID]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CTL_DOC_GUID] as 
select 
	Id, IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, 
	cast( GUID as varchar(100)) as GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale
	, IdDoc as idTemplate
 from ctl_doc


GO
