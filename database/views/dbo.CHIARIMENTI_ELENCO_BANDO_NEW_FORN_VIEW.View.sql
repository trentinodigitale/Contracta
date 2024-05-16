USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW_FORN_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW_FORN_VIEW]  AS

SELECT  --b.* , --'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME, id as ELENCOGrid_ID_DOC ,
	b.id,  b.DataCreazione, b.Domanda, b.Risposta, b.Allegato, b.UtenteDomanda, b.UtenteRisposta, 
	b.DataUltimaMod, b.Stato, b.ChiarimentoPubblico, b.aziragionesociale, b.azitelefono1, b.azifax, 
	b.azie_mail, b.Protocol, b.ChiarimentoEvaso, b.Notificato, b.DataRisposta, b.ProtocolRispostaQuesito, b.Fascicolo, b.Document, 
	b.DomandaOriginale, b.ProtocolloGenerale, b.DataProtocolloGenerale, b.StatoFunzionale, b.idPfuInCharge, b.ProtocolloGeneraleIN, 
	b.DataProtocolloGeneraleIN, b.Pubblicazione_auto_Richiesta,
	 case isnull(b.chiarimentoevaso,0)
		WHEN 0 THEN ''
		
		else ' ChiarimentoEvaso '
	  END AS Not_Editable,
	  --id_origin as ID_FROM
	  a.id as id_origin

	from document_chiarimenti a with (nolock)
			inner join document_chiarimenti b with (nolock) on b.ID_ORIGIN = a.ID_ORIGIN
		where b.protocol <> '' and b.protocol is not null and ISNULL(b.Document,'')='BANDO_QF'








GO
