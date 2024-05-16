USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_TESTATA_DOSSIER]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[DOCUMENT_TESTATA_DOSSIER] AS
SELECT     

	d.ID, 
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
	case  when tipodoc in ('CAMBIO_RUOLO_UTENTE','BANDO_FABBISOGNI', 'VERIFICA_REGISTRAZIONE','QUESTIONARIO_FABBISOGNI','NOTIER_ISCRIZ' ) then ma.mpIdAziMaster
		  when d.tipodoc='NOTIER_DDT' then isnull(dm.lnk,0)
		  when tipodoc ='CONVENZIONE' then dc.mandataria
		  when ISNULL(destinatario_azi,0)=0 then A2.IdAzi 
		  else Destinatario_Azi 
	end as muIdAziDest,
	case
		when tipodoc in ('CAMBIO_RUOLO_UTENTE','BANDO_FABBISOGNI', 'VERIFICA_REGISTRAZIONE','QUESTIONARIO_FABBISOGNI','NOTIER_ISCRIZ' ) then ma.mpIdAziMaster 
		when d.tipodoc='NOTIER_DDT' then isnull(dm.lnk,0)
		when tipodoc ='CONVENZIONE' then dc.mandataria
		when  ISNULL(destinatario_azi,0)=0 then A2.IdAzi 
		else Destinatario_Azi 
	end as AZI_Dest


	, l.DMV_CodExt as TipoAppalto 
	,b.TipoBandoGara AS TipoBando

 

FROM    
	CTL_DOC d  with (nolock)
		inner join profiliutente p with(nolock) on d.idpfu = p.idpfu 
		inner join Aziende A with(nolock) ON A.IdAzi = p.pfuidazi
		left join profiliutente p2 with(nolock) on d.Destinatario_User = p2.idpfu 
		left join aziende A2 with(nolock) on A2.IdAzi=P2.pfuIdAzi
		left join DOCUMENT_BANDO b with (nolock) on b.idheader =  d.id
		left outer join LIB_DomainValues l with(nolock) on l.DMV_DM_ID = 'Tipologia' and l.dmv_cod = b.TipoAppaltoGARA 
		left outer join document_convenzione DC  with(nolock) on d.id=dc.id
		left join ctl_doc_Value cv with(nolock)  on d.id=cv.idheader and cv.DSE_ID='DELIVERYCUSTOMERPARTY' and cv.DZT_Name='EndpointID_Destinatario'
		left join DM_Attributi dm with (nolock) on dm.vatValore_FT=cv.value and dm.dztNome='PARTICIPANTID' and idapp=1
		cross join (Select top 1 mpIdAziMaster from MarketPlace) as ma








GO
