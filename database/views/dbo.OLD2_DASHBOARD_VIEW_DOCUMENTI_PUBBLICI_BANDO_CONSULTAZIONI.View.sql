USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_BANDO_CONSULTAZIONI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[OLD2_DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_BANDO_CONSULTAZIONI] as
	
	SELECT 
			ctl_doc.id as IdMsg, 
			'' as IdDoc, 
			1000 as msgIType, 
			221 as msgISubType, 
			--TipoDoc + '_PORTALE' as OPEN_DOC_NAME,
			TipoDoc  as OPEN_DOC_NAME,
			IdPfu as IdMittente,
			0 as TipoAppalto,

			--CASE WHEN DataScadenza <GETDATE()
			--		THEN 1 
			--		ELSE 0 
			--END AS bScaduto,
			CASE WHEN isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) < getdate()
					THEN 1
					ELSE 0
			END as bScaduto,

			CASE WHEN r.DtScadenzaPubblEsito < GETDATE()  
					THEN 1
					ELSE 0
			END AS bConcluso ,

			'1' as EvidenzaPubblica,
			case CriterioAggiudicazioneGara 
				when 15531 then 1
				when 15532 then 2
				when 16291 then 3
			end as CriterioAggiudicazione, 
			ProtocolloBando,
			ProceduraGara as tipoprocedura, 
			case statodoc 
				when 'Sended' then '2' 
				else '1' 
			end as StatoGD,
			
			case StatoFunzionale
			when 'Revocato' then '<strong>Bando Revocato - </strong> ' + cast( Body as nvarchar(4000)) 
			when 'InRettifica' then '<strong>Bando in Rettifica - </strong> ' + cast( Body as nvarchar(4000)) 
			else
				case when isnull(v.linkeddoc,0) > 0 or isnull(Z.linkeddoc,0) > 0
					 then '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
				else
					cast( Body as nvarchar(4000)) 
				end
			end as Oggetto, 

			--ritornare avviso se tipobandogara=1
			'Consultazione Preliminare di Mercato' as Tipo, 

			'' as Contratto,

			aziRagioneSociale as DenominazioneEnte,

			'NO' as SenzaImporto,
			-- replace(str(ImportoBaseAsta, 25, 2),',','.') AS a_base_asta,
			dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta,
			'' as di_aggiudicazione,

			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , DataInvio, 126)) as DtPubblicazione, 
			-- Data di pubblicazione. serve per il tag rss pubDate
			left(convert( VARCHAR(50) , DataInvio, 126),19) as RECEIVEDDATAMSG,
			left(convert( VARCHAR(50) , DataInvio, 126),19) as DataInvio,

			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126)) AS DtScadenzaBando ,
			convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126) AS DtScadenzaBandoTecnical ,
			NULL as DtScadenzaPubblEsito,
			'' as RequisitiQualificazione,

			'' as CPV,
			'' as SCP,
			'' as URL,
			CIG, 
			--aggiunto ragionamento su QuesitoAnonimo
			CASE WHEN richiestaquesito = 1   and DataTermineQuesiti>getdate() and dz.DZT_ValueDef = 'SI'
				THEN 'YES'
				ELSE 'NO'
			END AS RichiestaQuesito,
			CASE WHEN r.ID_MSG_BANDO IS NULL 
				THEN 0 
				ELSE 1 
			END AS bEsito
			, 'SI'  AS VisualizzaQuesiti
			, '' as direzioneespletante

             ,ISNULL(Appalto_Verde,'no') as Appalto_Verde
			,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 

			, a.aziProvinciaLeg AS Provincia 
			, a.aziLocalitaLeg AS Comune 
			, a.aziIndirizzoLeg

			-- 'Province' as TipoEnte

			--, CASE isnull(viewTipoAmmin1.DMV_DescML,'') 
			--	WHEN '' THEN viewTipoAmmin2.dmv_descml
			--	ELSE viewTipoAmmin1.dmv_descml
			-- END AS TipoEnte 
			,  viewTipoAmmin2.dmv_descml as TipoEnte
			
			,case 
					when Appalto_Verde='si' and Acquisto_Sociale='si' then '<span class="imgbandi"><img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png"></span>'  
					when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">' 
					when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png">' 
			end as Bando_Verde_Sociale

				, ctl_doc.Fascicolo
				, case when M.CodFisGest is null then 0 else 1 end as Gestore
				, ctl_doc.Protocollo as RegistroSistema


		FROM ctl_doc with(nolock) 
			INNER JOIN aziende a with(nolock) on azienda = a.idazi
			INNER JOIN document_bando  with(nolock)  on id = idheader

			LEFT OUTER JOIN (
				select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito from Document_RisultatoDiGara with(nolock)	
					INNER JOIN  DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader and isnull(TipoDoc_src ,'')<>''
					) as r on r.ID_MSG_BANDO = -CTL_DOC.id


			LEFT OUTER JOIN (
							  SELECT dmv_descml, dmv_cod FROM
								lib_domainvalues  with(nolock) WHERE dmv_dm_id = 'TipoDiAmministr'
							) AS viewTipoAmmin2 ON viewTipoAmmin2.dmv_cod = a.TipoDiAmministr
			left  join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='PROROGA_CONSULTAZIONE') V on V.LinkedDoc=CTL_DOC.id
			left  join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='RETTIFICA_CONSULTAZIONE') Z on Z.LinkedDoc=CTL_DOC.id
			LEFT JOIN LIB_Dictionary DZ on DZ.DZT_Name='SYS_INSERISCIQUESITIDALPORTALE'

			-- VALORIZZIAMO LA COLONNNA BOOLEAN "GESTORE" PER INDICARE CHE LA GARA E' STATA CREATA DA UN ENTE TRA LE AZIENDE CON IL CODICE FISCALE DELL'AZI MASTER ( 1..N )

			LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = a.IdAzi and cfs.dztNome = 'codicefiscale'

			LEFT JOIN (
						select distinct cfs.vatValore_FT as CodFisGest
							from marketplace m with(nolock) 
									LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = mpIdAziMaster and cfs.dztNome = 'codicefiscale'
					) as M on M.CodFisGest = cfs.vatValore_FT

		WHERE tipodoc = 'BANDO_CONSULTAZIONE' and statofunzionale not in ('InLavorazione','InApprove') and deleted = 0 and evidenzapubblica = '1'


GO
