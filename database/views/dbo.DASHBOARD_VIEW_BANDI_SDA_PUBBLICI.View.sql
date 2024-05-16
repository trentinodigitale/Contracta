USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDI_SDA_PUBBLICI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_BANDI_SDA_PUBBLICI]  AS

select 

	CTL_DOC.id,
	IdPfu,
	-1 as msgIType,
	-1 as msgIsubType,
	titolo as Name,
	ProtocolloBando,
	ProtocolloGenerale,
	Protocollo as ProtocolloOfferta,
	DataScadenza as ReceidevDataMsg,
	cast(Body as nvarchar (2000)) as Oggetto,
	'' as Tipologia,
	DataScadenza AS ExpiryDate,
	'' as ImportoBaseAsta,
	'' as tipoprocedura,
	'' as StatoGd,
	Fascicolo,
	'' as CriterioAggiudicazione,
	'' as CriterioFormulazioneOfferta
	,'BANDO_SDA' as DOCUMENT 

	,isnull(  r.Id , 0 ) AS IDDOCR 
    ,CASE WHEN r.Id IS NULL THEN 0 ELSE 1 END AS Precisazioni
	,aziragioneSociale
	,ImportoBando

from CTL_DOC
	 inner join Document_Bando on Id=IDHEader
     inner join aziende on Azienda=Idazi
	left outer join  (
		select distinct id , ID_MSG_BANDO from Document_RisultatoDiGara with(nolock)	
					inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
					) as r on r.ID_MSG_BANDO = -CTL_DOC.id
	
where TipoDoc='BANDO_SDA' and statodoc='Sended' and deleted=0
GO
