USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_VIEW_CONFIG_MODELLI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CTL_DOC_VIEW_CONFIG_MODELLI] AS
	SELECT  d.Id, d.IdPfu, d.IdDoc, d.TipoDoc, d.StatoDoc, d.Data, d.Protocollo, d.PrevDoc, d.Deleted, d.Titolo, d.Body, d.Azienda, d.StrutturaAziendale, d.DataInvio, d.DataScadenza, 
			d.ProtocolloRiferimento, d.ProtocolloGenerale, d.Fascicolo, d.Note, d.DataProtocolloGenerale, d.LinkedDoc, d.SIGN_HASH, d.SIGN_ATTACH, d.SIGN_LOCK, d.JumpCheck, d.StatoFunzionale, 
			d.Destinatario_User, d.Destinatario_Azi, d.RichiestaFirma, d.NumeroDocumento, d.DataDocumento, d.Versione, d.VersioneLinkedDoc, d.GUID, d.idPfuInCharge, d.CanaleNotifica, d.URL_CLIENT, 
			d.Caption, d.FascicoloGenerale,
			case when N.id is null then '' else ' Titolo ' end as NotEditable,
			isnull(p.livelloBloccato,-1) as livelloBloccato
			--2 as livelloBloccato
		FROM CTL_DOC D
				left join CTL_DOC N with(nolock) on N.tipodoc = D.TipoDoc and N.id = D.PrevDoc and N.deleted = 0 
				left join Document_Parametri_Info_ADD p with(nolock) on p.deleted = 0 and modalitaDiScelta = 1


GO
