USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Comunicazioni_ENTRATE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Aziende_Comunicazioni_ENTRATE]
as
select   
	idMsg as ENTRATE_idMsg, 
	idAziControllata as ENTRATE_idAziControllata, 
	TipoComunicazione as ENTRATE_TipoComunicazione, 
	DataComunicazione as ENTRATE_DataComunicazione, 
	Protocol as ENTRATE_Protocol, 
	TipologiaAzienda as ENTRATE_TipologiaAzienda, 
	Esito as ENTRATE_Esito, 
	DataRilascio as ENTRATE_DataRilascio, 
	NoteComunicazione as ENTRATE_NoteComunicazione, 
	idAziDestinataria as ENTRATE_idAziDestinataria,
	idMsg as SEZ_ENTRATEGrid_ID_DOC 
	, idDoc_ContGara_For
,Document_Aziende_Comunicazioni.ProtocolloGenerale as ENTRATE_ProtocolloGenerale 
,Ufficio as ENTRATE_Ufficio
,Fax as ENTRATE_Fax,StatoEntrate
,Allegato as ENTRATE_Allegato
from Document_Aziende_Comunicazioni LEFT OUTER JOIN  Document_ControlliGara_Fornitori
ON Document_ControlliGara_Fornitori.IdRow=idDoc_ContGara_For
	where  TipoComunicazione = 'ENTRATE'


GO
