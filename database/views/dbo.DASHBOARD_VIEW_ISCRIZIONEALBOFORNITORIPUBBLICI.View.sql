USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI]  AS


select CTL_DOC.id as IdMsg,
		IdPfu,
		-1 as msgIType,
		-1 as msgIsubType,
		titolo as Name,
		ProtocolloGenerale as ProtocolloBando,
		Protocollo as ProtocolloOfferta,
		DataScadenza as ReceidevDataMsg,
		case StatoFunzionale when 'Revocato' then '<strong>Revocato - </strong> '	
			else ''
		end	+ cast( Body as nvarchar(4000)) as Oggetto,
		--cast(Body as nvarchar (2000)) as Oggetto,
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
			cross join ( select  dbo.PARAMETRI('PORTALE_PUBBLICO','BANDO','VIS_REVOCATI','SI',-1) as Vis_bandi_revocati ) as Vis_bandi_revocati 

	where TipoDoc='BANDO' and statodoc='Sended' and Deleted=0
		and ( ( StatoFunzionale <> 'Revocato' and Vis_bandi_revocati='NO') or Vis_bandi_revocati='SI' )
GO
