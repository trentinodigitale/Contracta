USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_ANNULLA_ORDINATIVO_TESTATA_DOSSIER]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DOCUMENT_ANNULLA_ORDINATIVO_TESTATA_DOSSIER] AS
SELECT     
	ID, 
	D.idPfu AS Doc_Owner, 
	case when ISNULL(Titolo,'') = '' then dbo.CNV(TipoDoc,'I') else Titolo end AS name, 
	datainvio as ReceivedDataMsg,
	p.pfuidazi AS AZI, 
	Protocollo AS NumOrdCliente, 
	A.aziRagioneSociale AS ragsoc, 
	1 AS IDMP, 
	Protocollo AS Protocol,
	Protocollo AS ProtocolloOfferta,
	Fascicolo as ProtocolBG,
	ProtocolloRiferimento as ProtocolloBando,
	case  -- when tipodoc in ('CAMBIO_RUOLO_UTENTE','BANDO_FABBISOGNI', 'VERIFICA_REGISTRAZIONE','QUESTIONARIO_FABBISOGNI' ) then ma.mpIdAziMaster
		  when StatoFunzionale = 'Approved'  then IdAziDest
		  when ISNULL(destinatario_azi,0)=0 then A2.IdAzi 
		  else Destinatario_Azi 
	end as muIdAziDest,
	case
		--when tipodoc in ('CAMBIO_RUOLO_UTENTE','BANDO_FABBISOGNI', 'VERIFICA_REGISTRAZIONE','QUESTIONARIO_FABBISOGNI' ) then ma.mpIdAziMaster 
		when StatoFunzionale = 'Approved'  then IdAziDest
		when ISNULL(destinatario_azi,0)=0 then A2.IdAzi 
		else Destinatario_Azi 
	end as AZI_Dest

FROM    CTL_DOC d 
	inner join profiliutente p on d.idpfu = p.idpfu 
	inner join Aziende  AS A ON A.IdAzi = p.pfuidazi
	inner join document_odc O on linkeddoc=rda_id
	left join profiliutente p2 on d.Destinatario_User = p2.idpfu 
	left join aziende A2 on A2.IdAzi=P2.pfuIdAzi
--	cross join (Select top 1 mpIdAziMaster from MarketPlace) as ma
where 
	TipoDoc='ANNULLA_ORDINATIVO'
GO
