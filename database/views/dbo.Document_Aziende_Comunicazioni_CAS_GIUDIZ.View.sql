USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Comunicazioni_CAS_GIUDIZ]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_Aziende_Comunicazioni_CAS_GIUDIZ]
as
select   
	idMsg as CAS_GIUDIZ_idMsg, 
	idAziControllata as CAS_GIUDIZ_idAziControllata, 
	TipoComunicazione as CAS_GIUDIZ_TipoComunicazione, 
	DataComunicazione as CAS_GIUDIZ_DataComunicazione, 
	Protocol as CAS_GIUDIZ_Protocol, 
	TipologiaAzienda as CAS_GIUDIZ_TipologiaAzienda, 
	Esito as CAS_GIUDIZ_Esito, 
	DataRilascio as CAS_GIUDIZ_DataRilascio, 
	NoteComunicazione as CAS_GIUDIZ_NoteComunicazione, 
	idAziDestinataria as CAS_GIUDIZ_idAziDestinataria,
	idMsg as SEZ_CAS_GIUDIZGrid_ID_DOC 
	, idDoc_ContGara_For
,Document_Aziende_Comunicazioni.ProtocolloGenerale as CAS_GIUDIZ_ProtocolloGenerale 
,Ufficio as CAS_GIUDIZ_Ufficio,CarichiPendenti,
Fax as CAS_GIUDIZ_Fax,StatoCas_Giudiz,
Allegato as CAS_GIUDIZ_Allegato
from Document_Aziende_Comunicazioni LEFT OUTER JOIN  Document_ControlliGara_Fornitori
ON Document_ControlliGara_Fornitori.IdRow=idDoc_ContGara_For
	where  TipoComunicazione = 'CAS_GIUDIZ'


GO
