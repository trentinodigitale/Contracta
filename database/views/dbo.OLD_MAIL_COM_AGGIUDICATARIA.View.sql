USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_COM_AGGIUDICATARIA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_MAIL_COM_AGGIUDICATARIA]
AS
	SELECT    id AS iddoc ,
			  'I' AS LNG ,
			  'Comunicazione Aggiudicataria' AS TipoDoc ,
			  a.aziragionesociale AS RagioneSociale ,
			  a.aziragionesociale AS RagioneSocialeMitt ,
			  DataCreazione ,
			  ID_MSG_PDA ,
			  ID_MSG_BANDO ,
			  Stato ,
			  ResponsabileContratto ,
			  Protocol ,
			  idAggiudicatrice ,
			  importoBaseAsta ,
			  NRDeterminazione ,
			  DataDetermina ,
			  ValutazioneEconomica ,
			  ProtocolloGenerale ,
			  DataProt ,
			  DirProponente ,
			  FaxProponente ,
			  FaxRUP ,
			  ImportoAggiudicato ,
			  OneriSic ,
			  OneriSicE ,
			  OneriSicI ,
			  OneriDis ,
			  LavoriEconomia ,
			  PercCauzione ,
			  CauzioneDefinitiva ,
			  CauzioneRidotta ,
			  RUP ,
			  NomeProponente ,
			  Titolo ,
			  Protocollo ,
			  StatoFunzionale ,
			  CanaleNotifica ,
			  CONVERT( VARCHAR , DataInvio , 103) AS DataInvio ,
			  CONVERT( VARCHAR , DataInvio , 108) AS OraInvio ,
			  Oggetto AS Body ,
			  'COM_AGGIUDICATARIA' AS TipoDocumento ,
			  p.pfunome ,
			  p.pfuE_mail ,
			  p1.pfunome AS pfunomedest ,
			  a1.aziragionesociale AS RagioneSocialeDest ,
			  p1.pfuE_mail AS pfuE_mailDest

				, case 
						when a1.azivenditore <> 0 then 'Operatore Economico'
						when a1.aziacquirente <> 0 then 'Ente'
				  end as TipoAziendaDestinatario

				, case 
						when a.azivenditore <> 0 then 'Operatore Economico'
						when a.aziacquirente <> 0 then 'Ente'
				  end as TipoAziendaMittente
				, '' as Attach_Grid

		FROM  Document_Com_Aggiudicataria d ,
			  profiliutente p ,
			  aziende a ,
			  profiliutente p1 ,
			  aziende a1
		WHERE p.pfuidazi = a.idazi
			  AND p.idpfu = d.idpfu
			  AND p1.pfuidazi = a1.idazi
			  AND a1.idazi = d.idaggiudicatrice
GO
