USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CHIARIMENTI_PORTALE_BANDO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_CHIARIMENTI_PORTALE_BANDO]  AS

	SELECT
	 
		a.id_origin, isnull(b.oggetto,c.body) as oggetto, isnull(b.name,c.titolo) as name, 
		isnull(b.protocollobando,band.ProtocolloBando) as ProtocolloBando, isnull(b.expirydate, band.DataScadenzaOfferta) as expirydate ,
		a.id ,a.domanda,a.aziragionesociale,a.azitelefono1,a.azifax,
		a.azie_mail,a.protocol,a.allegato,a.datacreazione,a.datacreazione as datacreazione1,a.chiarimentoevaso,
		a.ChiarimentoPubblico,a.Notificato,a.UtenteDomanda,a.UtenteRisposta,a.risposta,
		a.protocolrispostaquesito,a.datarisposta,
		
		--isnull(a.fascicolo,c.Fascicolo ) as fascicolo ,
		case when isnull(a.fascicolo,'')='' then c.Fascicolo else a.fascicolo end as fascicolo,
		
		a.domandaoriginale,
		a.ProtocolloGenerale, a.DataProtocolloGenerale
		,isnull(a.document,'') as Document
		, isnull(band.TipoProceduraCaratteristica,'') as TipoGara
		, c.Azienda
		, a.ProtocolloGeneraleIN
		, a.DataProtocolloGeneraleIN
	from document_chiarimenti a 
			left outer join CHIARIMENTI_PORTALE_FROM_BANDI b on a.id_origin=b.ID_ORIGIN and isnull(a.document,'') = '' -- Documento generico
			left outer join CTL_DOC c ON a.id_origin=c.id and ISNULL(a.Document,'') <> '' -- Documento nuovo
			LEFT OUTER JOIN Document_bando band ON c.id = band.idheader
		WHERE isnull( A.PROTOCOL , '' ) <> '' 







GO
