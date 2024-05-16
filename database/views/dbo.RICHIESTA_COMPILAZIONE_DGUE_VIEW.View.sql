USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_COMPILAZIONE_DGUE_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RICHIESTA_COMPILAZIONE_DGUE_VIEW] as
	
	select 
		C.Id, 
		C.IdPfu, 
		C.IdDoc, 
		C.TipoDoc, 
		C.StatoDoc, 
		C.Data, 
		C.Protocollo, 
		C.PrevDoc, 
		C.Deleted, 
		C.Titolo, 
		C.Body, 
		C.Azienda, 
		C.DataInvio, 
		C.DataScadenza, 
		C.ProtocolloRiferimento, 
		C.ProtocolloGenerale, 
		C.Fascicolo, 
		C.Note, 
		C.DataProtocolloGenerale, 
		C.LinkedDoc, 
		C.SIGN_HASH, 
		C.SIGN_ATTACH, 
		C.SIGN_LOCK, 
		C.JumpCheck, 
		C.StatoFunzionale, 
		C.Destinatario_User, 
		C.Destinatario_Azi, 
		C.RichiestaFirma, 
		C.NumeroDocumento, 
		C.DataDocumento, 
		C.Versione, 
		C.VersioneLinkedDoc, 
		C.GUID, 
		C.idPfuInCharge, 
		C.CanaleNotifica, 
		C.URL_CLIENT, 
		C.Caption, 
		C.FascicoloGenerale,
		C.JumpCheck as TipoRiferimento,
		C.body as Oggetto,
		DB.CUP,
		DB.DataIndizione,
		DB.NumeroIndizione,
		DB.CIG,
		CB.strutturaaziendale

	from ctl_doc C  --RICHIESTA
		inner join ctl_doc CO on CO.id=C.LinkedDoc  --OFFERTA
		inner join Document_Bando DB on CO.LinkedDoc=DB.idHeader  --BANDO
		inner join ctl_doc CB on CB.id=CO.LinkedDoc  --BANDO
	where C.tipodoc = 'RICHIESTA_COMPILAZIONE_DGUE'


GO
