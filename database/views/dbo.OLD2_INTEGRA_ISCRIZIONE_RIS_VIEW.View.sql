USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_INTEGRA_ISCRIZIONE_RIS_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_INTEGRA_ISCRIZIONE_RIS_VIEW] as 
select  d.Id, 
		d.IdPfu, 
		d.IdDoc, 
		d.TipoDoc, 
		d.StatoDoc, 
		d.Data, 
		d.Protocollo, 
		d.PrevDoc, 
		d.Deleted, 
		d.Titolo, 
		d.Body, 
		d.Azienda, 
		d.StrutturaAziendale, 
		d.DataInvio, 
		d.DataScadenza, 
		d.ProtocolloRiferimento, 
		d.ProtocolloGenerale, 
		d.Fascicolo, 
		d.Note, 
		d.DataProtocolloGenerale, 
		d.LinkedDoc, 
		d.SIGN_HASH, 
		d.SIGN_ATTACH, 
		d.SIGN_LOCK, 
		d.JumpCheck, 
		d.StatoFunzionale, 
		d.Destinatario_User, 
		d.RichiestaFirma, 
		d.NumeroDocumento, 
		d.DataDocumento, 
		d.Versione, 
		d.VersioneLinkedDoc, 
		d.GUID, 
		d.idPfuInCharge, 
		d.CanaleNotifica, 
		d.URL_CLIENT
		,i.Azienda as LegalPub
		,i.Protocollo as ProtocolloOfferta
		,CT.Value as Destinatario_azi
from CTL_DOC  d
	inner join CTL_DOC r on d.LinkedDoc = r.id -- richiesta di integrazione
	inner join CTL_DOC i on r.LinkedDoc = i.id -- istanza
	inner join CTL_DOC_VALUE CT on  CT.idheader=d.id and CT.DZT_NAME='Destinatario_Azi' and CT.DSE_ID='RISPOSTA'

GO
