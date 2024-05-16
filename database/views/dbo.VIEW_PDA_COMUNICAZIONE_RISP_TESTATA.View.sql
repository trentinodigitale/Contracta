USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PDA_COMUNICAZIONE_RISP_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_PDA_COMUNICAZIONE_RISP_TESTATA] as
select 
		Id,
		C.IdPfu,
		titolo,
		Protocollo,
		DataInvio,
		StatoFunzionale,
		ProtocolloGenerale,
		DataProtocolloGenerale,
		pfuidazi as Destinatario_Azi,
		azienda,
		ProtocolloRiferimento,
		TipoDoc,
		DataScadenza,
		Body,
		Note,
		LinkedDoc,
		PrevDoc,
		Fascicolo,
		StatoDoc,
		VersioneLinkedDoc
	from 
		CTL_DOC C
			inner join profiliutente P on P.idpfu=Destinatario_User
	where C.tipodoc =  'PDA_COMUNICAZIONE_RISP' 
						



GO
