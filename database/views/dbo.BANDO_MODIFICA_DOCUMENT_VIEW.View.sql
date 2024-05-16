USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_MODIFICA_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[BANDO_MODIFICA_DOCUMENT_VIEW] as

select 
	M.Id, 
	M.IdPfu, 
	M.IdDoc, 
	M.TipoDoc, 
	M.StatoDoc, 
	M.Data, 
	M.Protocollo, 
	M.PrevDoc, 
	M.Deleted, 
	M.Body, 
	M.Azienda, 
	M.StrutturaAziendale, 
	M.DataInvio, 
	M.DataScadenza, 
	M.ProtocolloRiferimento, 
	M.ProtocolloGenerale, 
	M.Fascicolo, 
	M.Note, 
	M.DataProtocolloGenerale, 
	M.LinkedDoc, 
	M.SIGN_HASH, 
	M.SIGN_ATTACH, 
	M.SIGN_LOCK, 
	M.JumpCheck, 
	M.StatoFunzionale, 
	M.Destinatario_User, 
	M.Destinatario_Azi, 
	M.RichiestaFirma, 
	M.NumeroDocumento, 
	M.DataDocumento, 
	M.Versione, 
	M.VersioneLinkedDoc, 
	M.GUID, 
	M.idPfuInCharge, 
	M.CanaleNotifica, 
	M.URL_CLIENT, 
	M.Caption, 
	M.FascicoloGenerale
	,CV.value as Titolo

from ctl_doc M
left  join CTL_DOC_Value CV on CV.IdHeader=M.id and CV.DSE_ID='TITOLO' and CV.DZT_Name='Titolo_OLD'

GO
