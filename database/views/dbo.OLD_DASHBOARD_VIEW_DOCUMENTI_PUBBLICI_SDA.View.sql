USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_SDA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD_DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_SDA] as

select 
	CTL_DOC.id as IdMsg,
	'' as IdDoc,
	-1 as iType,
	-1 as iSubType,
	'BANDO_SDA' as OPEN_DOC_NAME,
	IdPfu as IdMittente,
	'' as TipoAppalto,

    CASE WHEN DataScadenza <GETDATE()
            THEN 1 
            ELSE 0 
    END AS bScaduto,

    CASE WHEN r.DtScadenzaPubblEsito < GETDATE()  
            THEN 1
            ELSE 0
    END AS bConcluso ,

	'1' as EvidenzaPubblica,
	0 as CriterioAggiudicazioneGara,
	ProtocolloBando,
	Protocollo as ProtocolloOfferta,
	'' as TipoProcedura,
	'' as StatoGd,
	cast(Body as nvarchar (2000)) as Oggetto,
	'Bando' as Tipo,
	domVal.dmv_descml as Contratto,
	aziragioneSociale as DenominazioneEnte
	--'Province' as TipoEnte,
	,CASE isnull(viewTipoAmmin1.DMV_DescML,'') 
		WHEN '' THEN viewTipoAmmin2.dmv_descml
		ELSE viewTipoAmmin1.dmv_descml
	 END AS TipoEnte, 
	'NO' as SenzaImporto,
	dbo.FormatMoney(ImportoBando) as a_base_asta,
	'' as di_aggiudicazione
	, dbo.GETDATEDDMMYYYY ( convert( VARCHAR(50) ,DataInvio , 126)) AS DtPubblicazione
    , dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , DataScadenza, 126)) AS DtScadenzaBando 
    , convert( VARCHAR(50) , DataScadenza, 126) AS DtScadenzaBandoTecnical 
	, NULL as DtScadenzaPubblEsito
	, '' as RequisitiQualificazione
	, '' as CPV
	, '' as SCP
	, '' as URL
	, NULL as CIG
	, CASE WHEN richiestaquesito = 1
            THEN 'YES'
            ELSE 'NO'
      END AS RichiestaQuesito
	, CASE WHEN r.ID_MSG_BANDO IS NULL 
		THEN 0 
		ELSE 1 
      END AS bEsito
	, 'SI' AS VisualizzaQuesiti
	, aziende.aziProvinciaLeg AS Provincia 
    , aziende.aziLocalitaLeg AS Comune 
    , aziende.aziIndirizzoLeg

	, titolo as titoloDocumento
	,statoFunzionale

	, convert( VARCHAR(50) , DataInvio, 126) as DtPubblicazioneTecnical
	, convert(varchar ,DataScadenza,126)  as DataChiusuraTecnical

from CTL_DOC with(nolock)
	 inner join Document_Bando with(nolock) on Id=IDHEader
     inner join aziende with(nolock) on Azienda=Idazi

	 left outer join (
			select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito 
				from Document_RisultatoDiGara with(nolock)	
						inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
					) as r on r.ID_MSG_BANDO = -CTL_DOC.id
	
	-- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
	inner join (
			select dmv_descml, dmv_cod 
				from lib_domainvalues with(nolock)
				where dmv_dm_id = 'Tipologia'
			   ) as domVal on domVal.dmv_cod = Document_Bando.TipoAppaltoGara

	-- Se è presente la StrutturaAziendale ed è avvalorata recupero la descrizione dell'ente espletante da li altrimenti 
	-- da dall'azienda presente nel campo 'azienda' del documento
	LEFT OUTER JOIN (
						SELECT DISTINCT 
							Descrizione AS DMV_DescML,
							CAST(IdAz AS varchar) + '#' + Path AS DMV_Cod
						FROM AZ_STRUTTURA  with(nolock)
						) AS viewTipoAmmin1 ON viewTipoAmmin1.dmv_cod = ctl_doc.StrutturaAziendale

	LEFT OUTER JOIN (
						SELECT dmv_descml, dmv_cod FROM
						lib_domainvalues  with(nolock) WHERE dmv_dm_id = 'TipoDiAmministr'
					) AS viewTipoAmmin2 ON viewTipoAmmin2.dmv_cod = aziende.TipoDiAmministr
			    
where TipoDoc='BANDO_SDA' and statodoc='Sended' and StatoFunzionale in ( 'Pubblicato','InRettifica', 'Revocato', 'Chiuso') and deleted=0




GO
