USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONFIG_MODELLI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_CONFIG_MODELLI] as 
	select a.Id, a.IdPfu, a.IdDoc, a.TipoDoc, a.StatoDoc, a.Data, a.Protocollo, a.PrevDoc, a.Deleted, a.Body, a.Azienda, a.StrutturaAziendale, a.DataInvio, a.DataScadenza, a.ProtocolloRiferimento, a.ProtocolloGenerale, a.Fascicolo, a.Note, a.DataProtocolloGenerale, a.LinkedDoc, a.SIGN_HASH, a.SIGN_ATTACH, a.SIGN_LOCK, a.JumpCheck, a.StatoFunzionale, a.Destinatario_User, a.Destinatario_Azi, a.RichiestaFirma, a.NumeroDocumento, a.DataDocumento, a.Versione, a.VersioneLinkedDoc, a.GUID, a.idPfuInCharge, a.CanaleNotifica, a.URL_CLIENT, a.Caption, a.FascicoloGenerale,
			case when N.id is null then a.titolo else '<b>( In Modifica )</b> ' + a.titolo end as Titolo
		from CTL_DOC a with(nolock)
				left join CTL_DOC N with(nolock) on N.tipodoc = a.tipodoc and N.statofunzionale in ( 'InLavorazione'  ) and N.PrevDoc = a.id and N.deleted = 0  and isnull(N.LinkedDoc,0) = 0
		where a.tipodoc in ('CONFIG_MODELLI', 'CONFIG_MODELLI_FABBISOGNI' ) and a.deleted = 0 and ISNULL(a.LinkedDoc,0) = 0


GO
