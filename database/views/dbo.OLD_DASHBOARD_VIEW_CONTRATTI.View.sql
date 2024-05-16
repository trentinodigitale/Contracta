USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CONTRATTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW  [dbo].[OLD_DASHBOARD_VIEW_CONTRATTI] as
select w.*,P.IdPfu as Owner from 
		(	select Id, IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale, OPEN_DOC_NAME, muidazidest, TipoProceduraCaratteristica from DASHBOARD_VIEW_SCRITTURA_PRIVATA
				union all 
			select Id, IdPfu, IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, DataScadenza, ProtocolloRiferimento, ProtocolloGenerale, Fascicolo, Note, DataProtocolloGenerale, LinkedDoc, SIGN_HASH, SIGN_ATTACH, SIGN_LOCK, JumpCheck, StatoFunzionale, Destinatario_User, Destinatario_Azi, RichiestaFirma, NumeroDocumento, DataDocumento, Versione, VersioneLinkedDoc, GUID, idPfuInCharge, CanaleNotifica, URL_CLIENT, Caption, FascicoloGenerale, OPEN_DOC_NAME, muidazidest, TipoProceduraCaratteristica from DASHBOARD_VIEW_CONTRATTO_GARA
		) as w
			inner join ProfiliUtente P with(NOLOCK) on P.pfuidazi=W.azienda and P.pfudeleted=0


GO
