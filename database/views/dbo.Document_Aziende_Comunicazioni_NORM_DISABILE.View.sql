USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Comunicazioni_NORM_DISABILE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Aziende_Comunicazioni_NORM_DISABILE]
as
select   
	idMsg as NORM_DISABILE_idMsg, 
	idAziControllata as NORM_DISABILE_idAziControllata, 
	TipoComunicazione as NORM_DISABILE_TipoComunicazione, 
	DataComunicazione as NORM_DISABILE_DataComunicazione, 
	Protocol as NORM_DISABILE_Protocol, 
	TipologiaAzienda as NORM_DISABILE_TipologiaAzienda, 
	Esito as NORM_DISABILE_Esito, 
	DataRilascio as NORM_DISABILE_DataRilascio, 
	NoteComunicazione as NORM_DISABILE_NoteComunicazione, 
	idAziDestinataria as NORM_DISABILE_idAziDestinataria,
	idMsg as SEZ_NORM_DISABILEGrid_ID_DOC 
	, idDoc_ContGara_For
	,Document_Aziende_Comunicazioni.ProtocolloGenerale as NORM_DISABILE_ProtocolloGenerale 
	,Ufficio as NORM_DISABILE_Ufficio, Fax as NORM_DISABILE_Fax,StatoNorm_Disabile
	,Allegato as NORM_DISABILE_Allegato
from Document_Aziende_Comunicazioni LEFT OUTER JOIN  Document_ControlliGara_Fornitori
ON Document_ControlliGara_Fornitori.IdRow=idDoc_ContGara_For
	where  TipoComunicazione IN ( 'NORM_DISABILE',  'L68/69')



GO
