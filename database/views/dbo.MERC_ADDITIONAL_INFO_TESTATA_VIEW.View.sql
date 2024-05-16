USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MERC_ADDITIONAL_INFO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[MERC_ADDITIONAL_INFO_TESTATA_VIEW]  as
select 
	Id, IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, 
	Titolo, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, 
	ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH,
	SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi,
	RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc,
	GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale,	
	CV.Value as Classeiscriz,
	CV2.Value as Body
from ctl_doc
	inner join CTL_DOC_Value CV on Id=CV.IdHeader and CV.DSE_ID='CLASSE' and CV.DZT_Name='Classeiscriz' and CV.Row=0
	left join CTL_DOC_Value CV2 on Id=CV2.IdHeader and CV2.DSE_ID='CLASSE' and CV2.DZT_Name='Body' and CV2.Row=0
where TipoDoc like '%MERC_ADDITIONAL_INFO'

GO
