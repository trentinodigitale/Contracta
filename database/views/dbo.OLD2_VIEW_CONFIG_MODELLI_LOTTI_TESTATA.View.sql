USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_CONFIG_MODELLI_LOTTI_TESTATA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD2_VIEW_CONFIG_MODELLI_LOTTI_TESTATA] as

	Select 
		  D1.Id,
		  D1.IdPfu, 
		  D1.IdDoc, 
		  D1.TipoDoc, 
		  D1.StatoDoc, 
		  D1.Data, 
		  D1.Protocollo, 
		  D1.PrevDoc, 
		  D1.Deleted, 
		  D1.Titolo, 
		  D1.Body, 
		  D1.Azienda, 
		  D1.StrutturaAziendale, 
		  D1.DataInvio, 
		  D1.DataScadenza, 
		  D1.ProtocolloRiferimento, 
		  D1.ProtocolloGenerale, 
		  D1.Fascicolo, 
		  D1.body as Note, 
		  D1.DataProtocolloGenerale, 
		  D1.LinkedDoc, 
		  D1.SIGN_HASH, 
		  D1.SIGN_ATTACH, 
		  D1.SIGN_LOCK, 
		  D1.JumpCheck, 
		  D1.StatoFunzionale, 
		  D1.Destinatario_User, 
		  D1.Destinatario_Azi, 
		  D1.RichiestaFirma, 
		  D1.NumeroDocumento, 
		  D1.DataDocumento, 
		  D1.Versione, 
		  D1.VersioneLinkedDoc, 
		  D1.GUID, 
		  D1.idPfuInCharge, 
		  D1.CanaleNotifica, 
		  D1.URL_CLIENT, 
		  D1.Caption, 
		  D1.FascicoloGenerale,
		  case when rtrim( d1.StatoFunzionale ) = 'Pubblicato' or d1.statoDoc <> 'Saved' or N.id is not null then ' Titolo ' else '' end as NotEditable,
		  '' as CIG,
		  0 as GiroContratto,
		  '' as GeneraConvenzione ,
		  GARE_IN_MODIFICA_O_RETTIFICA,
		  '' as TipoProceduraCaratteristica
	from CTL_DOC D1
			left join CTL_DOC N with(nolock) on N.tipodoc = D1.TipoDoc and N.id = D1.PrevDoc and N.deleted = 0 
			cross join ( select dbo.GetBandiInRettificaOModifica( ) as GARE_IN_MODIFICA_O_RETTIFICA ) as girm
	where d1.tipodoc='CONFIG_MODELLI_LOTTI' and ISNULL(d1.linkedDoc,0) = 0

	--prendo le informazioni per i modelli di gara
	UNION ALL

	Select
		  D1.Id,
		  D1.IdPfu, 
		  D1.IdDoc, 
		  D1.TipoDoc, 
		  D1.StatoDoc, 
		  D1.Data, 
		  D1.Protocollo, 
		  D1.PrevDoc, 
		  D1.Deleted, 
		  D1.Titolo, 
		  D1.Body, 
		  D2.Azienda, 
		  D1.StrutturaAziendale, 
		  D1.DataInvio, 
		  D1.DataScadenza, 
		  D1.ProtocolloRiferimento, 
		  D2.ProtocolloGenerale, 
		  D2.Fascicolo, 
		  D2.body as Note, 
		  D2.DataProtocolloGenerale, 
		  D1.LinkedDoc, 
		  D1.SIGN_HASH, 
		  D1.SIGN_ATTACH, 
		  D1.SIGN_LOCK, 
		  D1.JumpCheck, 
		  D1.StatoFunzionale, 
		  D1.Destinatario_User, 
		  D1.Destinatario_Azi, 
		  D1.RichiestaFirma, 
		  D1.NumeroDocumento, 
		  D1.DataDocumento, 
		  D1.Versione, 
		  D2.TipoDoc as VersioneLinkedDoc, 
		  D1.GUID, 
		  D1.idPfuInCharge, 
		  D1.CanaleNotifica, 
		  D1.URL_CLIENT, 
		  D1.Caption, 
		  D1.FascicoloGenerale,
		  case when rtrim( d1.StatoFunzionale ) = 'Pubblicato' or d1.statoDoc <> 'Saved' or N.id is not null then ' Titolo ' else '' end as NotEditable,
		  CIG,
		  case when d2.tipodoc = 'BANDO_GARA' and GeneraConvenzione = '0' and tipoProceduraCaratteristica <> 'RDO' then 1 else 0 end as GiroContratto,
		  GeneraConvenzione ,
		  GARE_IN_MODIFICA_O_RETTIFICA,
		  TipoProceduraCaratteristica

	from CTL_DOC D1
			left join CTL_DOC N with(nolock)       on N.tipodoc = D1.TipoDoc and N.id = D1.PrevDoc and N.deleted = 0 
			inner join ctl_doc D2 with(nolock)     on D1.LinkedDoc = D2.Id 
			inner join Document_bando with(nolock) on D2.id=idheader 			
			cross join ( select dbo.GetBandiInRettificaOModifica( ) as GARE_IN_MODIFICA_O_RETTIFICA ) as girm
	where D1.tipodoc='CONFIG_MODELLI_LOTTI' and ISNULL(D1.linkedDoc,0) > 0

GO
