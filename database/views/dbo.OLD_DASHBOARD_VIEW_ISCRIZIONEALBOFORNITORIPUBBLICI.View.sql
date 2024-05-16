USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI]  AS


select CTL_DOC.id as IdMsg,
		IdPfu,
		-1 as msgIType,
		-1 as msgIsubType,
		titolo as Name,
		ProtocolloGenerale as ProtocolloBando,
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
		, 'BANDO' as DOCUMENT 

		, isnull(  r.Id , 0 ) AS IDDOCR 
		, CASE WHEN r.Id IS NULL THEN 0 ELSE 1 END AS Precisazioni
		, dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , DataInvio, 126)) as DtPubblicazione
		, convert( VARCHAR(50) , DataInvio, 126) as DtPubblicazioneTecnical
		, ISNULL(JumpCheck,'') as JumpCheck
		, StatoFunzionale
		, convert( VARCHAR(50) , DataScadenza, 126)  as DtScadenzaBandoTecnical

		, azi.aziRagioneSociale as DenominazioneEnte
		, case when M.CodFisGest is null then 0 else 1 end as Gestore
		, CTL_DOC.Protocollo as RegistroSistema

	from CTL_DOC with(nolock)
			INNER JOIN Aziende azi with(nolock) ON azi.IdAzi = CTL_DOC.Azienda
			LEFT OUTER JOIN  
				(
					select distinct id , ID_MSG_BANDO 
						from Document_RisultatoDiGara with(nolock)	
								inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
				) as r on r.ID_MSG_BANDO = -CTL_DOC.id

			-- VALORIZZIAMO LA COLONNNA BOOLEAN "GESTORE" PER INDICARE CHE LA GARA E' STATA CREATA DA UN ENTE TRA LE AZIENDE CON IL CODICE FISCALE DELL'AZI MASTER ( 1..N )
			LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = CTL_DOC.azienda and cfs.dztNome = 'codicefiscale'

			LEFT JOIN (
						select distinct cfs.vatValore_FT as CodFisGest
							from marketplace m with(nolock) 
									LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = mpIdAziMaster and cfs.dztNome = 'codicefiscale'
					) as M on M.CodFisGest = cfs.vatValore_FT


	where TipoDoc='BANDO' and statodoc='Sended' and Deleted=0

--UNION ALL
--SELECT M.IdMsg
--	, umIdPfu AS IdPfu
--	, msgIType
--	, msgISubType
--	,TMF.Name
--	,TMF.ProtocolloBando
--	,TMF.ProtocolloOfferta
--	,TMF.ReceivedDataMsg
--	,TMF.[Object] as Oggetto
--	, CASE TMF.tipoappalto
--		WHEN '' THEN ''
--		ELSE dbo.GetCodFromCodExt('Tipologia',TMF.tipoappalto )
--	END AS Tipologia
--	,TMF.ExpiryDate
--	,TMF.ImportoBaseAsta
--	, CASE ProceduraGara
--			WHEN '' THEN ''
--			ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
--	END AS tipoprocedura
--	, TMF.Stato AS StatoGD
--	,TMF.ProtocolBG as Fascicolo
--	, CASE AggiudicazioneGara
--		WHEN '' THEN ''
--		ELSE dbo.GetCodFromCodExt('Criterio',AggiudicazioneGara )
--	END AS CriterioAggiudicazione
--	, CASE CriterioFormulazioneOfferte
--		WHEN '' THEN ''
--		ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
--	END AS CriterioFormulazioneOfferta
--	,'' as DOCUMENT 
--	,0 as IDDOCR 
--    ,0 AS Precisazioni
--	, NULL as DtPubblicazione
--	, NULL as DtPubblicazioneTecnical
--	, '' as jumpcheck
--	, 'Pubblicato' as StatoFunzionale
--	, NULL as DtScadenzaBandoTecnical
--FROM 
--	multilinguismo, 
--	folderdocuments, 
--	foldertypes, 
--	document,  
--	msgpermissions, 
--	tab_utenti_messaggi, 
--	tab_messaggi M,
--	tab_messaggi_fields TMF
--WHERE 
--	ftidpf = fdidpf 
--	and fdidpfu = mpidpfu  
--	and fdIdMsg = mpIdMsg 
--	and umIdMsg = M.IdMsg  
--	and fdIdMsg = umIdMsg 
--	and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
--	and fdIdPf = 12
--	and msgIType = dcmIType  
--	and msgISubType = dcmISubType  
--	and ftiddcm = iddcm  
--	and umIdPfu = -10 
--	and ftdeleted = 0  
--	and dcmDeleted = 0  
--	and mpidPfu = -10
--    and TMF.IdMsg = M.IdMsg  	


GO
