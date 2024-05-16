USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Comunicazioni_CANC_FALLIMENTARE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_Aziende_Comunicazioni_CANC_FALLIMENTARE]
as
select   
	idMsg as CANC_FALLIMENTARE_idMsg, 
	idAziControllata as CANC_FALLIMENTARE_idAziControllata, 
	TipoComunicazione as CANC_FALLIMENTARE_TipoComunicazione, 
	DataComunicazione as CANC_FALLIMENTARE_DataComunicazione, 
	Protocol as CANC_FALLIMENTARE_Protocol, 
	TipologiaAzienda as CANC_FALLIMENTARE_TipologiaAzienda, 
	Esito as CANC_FALLIMENTARE_Esito, 
	DataRilascio as CANC_FALLIMENTARE_DataRilascio, 
	NoteComunicazione as CANC_FALLIMENTARE_NoteComunicazione, 
	idAziDestinataria as CANC_FALLIMENTARE_idAziDestinataria,
	idMsg as SEZ_CANC_FALLIMENTAREGrid_ID_DOC 
	, idDoc_ContGara_For
	,allegato as CANC_FALLIMENTARE_Allegato

,Document_Aziende_Comunicazioni.ProtocolloGenerale as CANC_FALLIMENTARE_ProtocolloGenerale 
,Ufficio as CANC_FALLIMENTARE_Ufficio,
Fax as CANC_FALLIMENTARE_Fax,StatoCanc_Fallimentare
from Document_Aziende_Comunicazioni LEFT OUTER JOIN  Document_ControlliGara_Fornitori
ON Document_ControlliGara_Fornitori.IdRow=idDoc_ContGara_For
	where  TipoComunicazione = 'CANC_FALLIMENTARE'


GO
