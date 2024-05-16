USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Comunicazioni_NORM_ANTIMAFIA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_Aziende_Comunicazioni_NORM_ANTIMAFIA]
as
select   
	idMsg as NORM_ANTIMAFIA_idMsg, 
	idAziControllata as NORM_ANTIMAFIA_idAziControllata, 
	TipoComunicazione as NORM_ANTIMAFIA_TipoComunicazione, 
	DataComunicazione as NORM_ANTIMAFIA_DataComunicazione, 
	Protocol as NORM_ANTIMAFIA_Protocol, 
	TipologiaAzienda as NORM_ANTIMAFIA_TipologiaAzienda, 
	Esito as NORM_ANTIMAFIA_Esito, 
	DataRilascio as NORM_ANTIMAFIA_DataRilascio, 
	NoteComunicazione as NORM_ANTIMAFIA_NoteComunicazione, 
	idAziDestinataria as NORM_ANTIMAFIA_idAziDestinataria,
	idMsg as SEZ_NORM_ANTIMAFIAGrid_ID_DOC 
	, idDoc_ContGara_For
	,Document_Aziende_Comunicazioni.ProtocolloGenerale as NORM_ANTIMAFIA_ProtocolloGenerale 
	,Ufficio as NORM_ANTIMAFIA_Ufficio 
	,EstremiAffidamento
	,ValoreContratto
	,RiferimentiPrecedenti
	,OriginaleCopia,Fax as NORM_ANTIMAFIA_Fax,StatoNorm_Antimafia
	,NORM_ANTIMAFIA_DataScadenza
	,Allegato as NORM_ANTIMAFIA_Allegato
from Document_Aziende_Comunicazioni LEFT OUTER JOIN  Document_ControlliGara_Fornitori
ON Document_ControlliGara_Fornitori.IdRow=idDoc_ContGara_For
	where  TipoComunicazione = 'NORM_ANTIMAFIA'
GO
