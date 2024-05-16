USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AQ_RICHIESTAQUOTA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_AQ_RICHIESTAQUOTA] AS
	SELECT    
	D.ID as IdHeader,
	D.Id as IDDOC, 
	'I' as LNG,
	D.IdPfu, 
	D.TipoDoc, 
	D.StatoDoc, 
	D.Data, 
	D.Protocollo, 
	D.PrevDoc, 
	D.Titolo, 
	D.Body, 
	D.Azienda, 
	D.StrutturaAziendale, 
	convert( varchar , D.DataInvio , 103 ) as DataInvio, 
	D.DataScadenza, 
	DB.Protocollo as ProtocolloRiferimento, 
	D.ProtocolloGenerale, 
	D.Fascicolo, 
	D.Note, 
	D.DataProtocolloGenerale, 
	D.LinkedDoc, 
	D.SIGN_HASH, 
	D.SIGN_ATTACH, 
	D.SIGN_LOCK, 
	D.JumpCheck, 
	D.StatoFunzionale, D.Destinatario_User, D.Destinatario_Azi ,
	Document_Convenzione_Quote.Importo,
	Document_Convenzione_Quote.ImportoRichiesto,
	Document_Convenzione_Quote.Motivazione,
	--C.NumOrd,
	DB.Body as BodyContratto,
	C.ImportoBaseAsta as  Total ,
	P.pfunome as Nome

	FROM         
	ctl_doc D with(nolock)
		inner join Aziende with(nolock) on Azienda=IdAzi
		inner join ProfiliUtente P with(nolock) on P.idpfu=D.idpfu
		inner join Document_bando C with(nolock) on LinkedDoc=C.idHeader
		inner join CTL_DOC DB with(nolock) on DB.id=C.idHeader
		left join Document_Convenzione_Quote with(nolock)  on Document_Convenzione_Quote.idHeader=D.Id
	where D.TipoDoc='AQ_RICHIESTAQUOTA' and D.deleted=0 and D.statodoc='Sended'
GO
