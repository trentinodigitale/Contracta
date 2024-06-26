USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_MODELLI_LOTTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_MODELLI_LOTTI] as 

	select	d.Id, d.IdPfu, d.IdDoc, d.TipoDoc, d.StatoDoc, d.Data, d.Protocollo, d.PrevDoc, d.Deleted, d.Body, d.Azienda, d.StrutturaAziendale, d.DataInvio, d.DataScadenza, d.ProtocolloRiferimento, d.ProtocolloGenerale, d.Fascicolo, d.Note, d.DataProtocolloGenerale, d.LinkedDoc, d.SIGN_HASH, d.SIGN_ATTACH, d.SIGN_LOCK, d.JumpCheck, d.StatoFunzionale, d.Destinatario_User, d.Destinatario_Azi, d.RichiestaFirma, d.NumeroDocumento, d.DataDocumento, d.Versione, d.VersioneLinkedDoc, d.GUID, d.idPfuInCharge, d.CanaleNotifica, d.URL_CLIENT, d.Caption, d.FascicoloGenerale, 
			v.value as MacroAreaMerc,
			case when N.id is null then D.titolo else '<b>( In Modifica )</b> ' + dbo.HTML_Encode(D.titolo) end as Titolo
			,v2.Value as TipoProcedureApplicate
		from CTL_DOC d
			left outer join CTL_DOC_VALUE v on d.id = v.idheader and v.dzt_name = 'MacroAreaMerc' --and v.DSE_ID = 'AMBITO'
			left join CTL_DOC N with(nolock) on N.tipodoc = d.TipoDoc and N.statofunzionale in ( 'InLavorazione'  ) and N.PrevDoc = D.id and N.deleted = 0  and isnull(n.LinkedDoc,0) = 0
			left outer join CTL_DOC_VALUE v2 on d.id = v2.idheader and v2.dzt_name = 'TipoProcedureApplicate' and v2.DSE_ID = 'CRITERI'
	where d.tipodoc = 'CONFIG_MODELLI_LOTTI' and d.deleted = 0 and ISNULL(d.LinkedDoc,0) = 0 





GO
