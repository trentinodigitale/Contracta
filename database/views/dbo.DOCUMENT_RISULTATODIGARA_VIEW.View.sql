USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_RISULTATODIGARA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DOCUMENT_RISULTATODIGARA_VIEW]
AS
SELECT dr.Id
     , dr.DataCreazione
     , dr.ID_MSG_BANDO
     , dr.Precisazione
     , dr.DocumentoAllegato
     , dr.Oggetto
     , dr.TipoDoc_src
     , COALESCE(NULLIF(dr.ValoreContratto, 0), v.ValoreContratto) AS ValoreContratto
	 , dr.DataPubbEsito
     , dr.CodSCP
     , dr.UrlSCP
  FROM DOCUMENT_RISULTATODIGARA dr
		INNER JOIN TAB_MESSAGGI_FIELDS tf ON tf.IdMsg = dr.ID_MSG_BANDO
			LEFT JOIN DASHBOARD_VIEW_COM_AGGIUDICATARIA v ON tf.ProtocolloBando = v.Protocol

union 
--aggiungo i risultati di gara sui nuovi bandi
SELECT dr.Id
     , dr.DataCreazione
     , -dr.ID_MSG_BANDO as ID_MSG_BANDO
     , dr.Precisazione
     , dr.DocumentoAllegato
     , dr.Oggetto
     , dr.TipoDoc_src
     , dr.ValoreContratto
	 , dr.DataPubbEsito
     , dr.CodSCP
     , dr.UrlSCP
  FROM DOCUMENT_RISULTATODIGARA dr
		INNER JOIN CTL_DOC T ON -T.ID = dr.ID_MSG_BANDO and T.TipoDoc =dr.TipoDoc_src

GO
