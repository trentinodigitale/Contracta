USE [AFLink_TND]
GO
/****** Object:  View [dbo].[QUESTIONARIO_PROGRAMMAZIONE_COPERTINA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[QUESTIONARIO_PROGRAMMAZIONE_COPERTINA_VIEW] as
select
	C1.Id, C1.IdPfu, C1.IdDoc, C1.TipoDoc, C1.StatoDoc, C1.Data, C1.Protocollo, C1.PrevDoc, C1.Deleted, C1.Titolo,C1.Azienda, C1.StrutturaAziendale, C1.DataInvio, C1.DataScadenza, C1.ProtocolloRiferimento, C1.ProtocolloGenerale, C1.Fascicolo, C1.Note, C1.DataProtocolloGenerale, C1.LinkedDoc, C1.SIGN_HASH, C1.SIGN_ATTACH, C1.SIGN_LOCK, C1.JumpCheck, C1.StatoFunzionale, C1.Destinatario_User, C1.Destinatario_Azi, C1.RichiestaFirma, C1.NumeroDocumento, C1.DataDocumento, C1.Versione, C1.VersioneLinkedDoc, C1.GUID, C1.idPfuInCharge, C1.CanaleNotifica, C1.URL_CLIENT, C1.Caption, C1.FascicoloGenerale,
	C2.Body,
	DB.IdentificativoIniziativa,
	DB.DataRiferimentoFine,
	DB.TipoBando,
	DB.DataPresentazioneRisposte,
	CD.IdPfu as UTENTE_INCHARGE_DOC_IA,
	c2.StatoFunzionale as statobando 


from ctl_doc C1 
	inner join CTL_DOC C2 on c1.LinkedDoc=C2.id --and C2.tipodoc='BANDO_FABBISOGNI'
	inner join Document_Bando DB on DB.idheader=C2.id
	left join CTL_DOC_Destinatari CD on CD.idHeader=C1.LinkedDoc and C1.Azienda=CD.IdAzi


GO
