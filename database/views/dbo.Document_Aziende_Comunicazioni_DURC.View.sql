USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Comunicazioni_DURC]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_Aziende_Comunicazioni_DURC]
as
select   
	Document_Aziende_Comunicazioni.idMsg as DURC_idMsg, 
	idAziControllata as DURC_idAziControllata, 
	TipoComunicazione as DURC_TipoComunicazione, 
	DataComunicazione as DURC_DataComunicazione, 
	Protocol as DURC_Protocol, 
	TipologiaAzienda as DURC_TipologiaAzienda, 
	Esito as DURC_Esito, 
	DataRilascio as DURC_DataRilascio, 
	NoteComunicazione as DURC_NoteComunicazione, 
	idAziDestinataria as DURC_idAziDestinataria,
	Document_Aziende_Comunicazioni.idMsg as SEZ_DURCGrid_ID_DOC,
	idDoc_ContGara_For,
	StatoDURC,DURC_DataControllo
	,Document_Aziende_Comunicazioni_Allegati.allegato as DURC_ALLEGATO
from Document_Aziende_Comunicazioni 
	LEFT OUTER JOIN  Document_ControlliGara_Fornitori ON Document_ControlliGara_Fornitori.IdRow=idDoc_ContGara_For
	LEFT OUTER JOIN Document_Aziende_Comunicazioni_Allegati on idDoc_ContGara_For=Document_Aziende_Comunicazioni_Allegati.IdMsg 
		--	and Document_Aziende_Comunicazioni_Allegati.idrow=(Select Max(IdRow) from Document_Aziende_Comunicazioni_Allegati where idDoc_ContGara_For=IdMsg)
	where  TipoComunicazione = 'DURC'


GO
