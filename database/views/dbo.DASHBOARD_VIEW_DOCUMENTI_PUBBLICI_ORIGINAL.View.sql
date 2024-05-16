USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_ORIGINAL]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_ORIGINAL] AS

select portale.*
		, left(convert(VARCHAR(50) , isnull(fascicolo.ultimaModifica, portale.dataCreazione) , 126), 19) as dataUltimaModifica --utile per gli rss per ottenere un filtro sull'elenco delle gare per data ultima modifica, allo scopo di ottenere solo le gare che hanno avuto una modifica rispetto all'ultimo recupero
	FROM (

		SELECT 
			ctl_doc.id as IdMsg, 
			'' as IdDoc, 
			1000 as msgIType, 
			221 as msgISubType, 

			'BANDO_GARA' as OPEN_DOC_NAME,
			IdPfu as IdMittente,
			0 as TipoAppalto,

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
				when  'Sospeso' then '<strong>Procedura Sospesa - </strong> ' + cast(Body as nvarchar (4000)) 
				when  'InSospensione' then '<strong>Procedura in Sospensione - </strong> ' + cast(Body as nvarchar (4000)) 
				else
					case 
						when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  'RIPRISTINO_GARA' then '<strong>Procedura Ripristinata - </strong> ' + cast( Body as nvarchar(4000)) 
						when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> 'RIPRISTINO_GARA' then  '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
					else
					cast( Body as nvarchar(4000)) 
					end		
			end as Oggetto, 

			'Bando' as Tipo, 

			CASE domVal.DMV_CodExt
					WHEN '15495' THEN 'Forniture'
					WHEN '15496' THEN 'Lavori'
					WHEN '15494' THEN 'Servizi'
					ELSE 'Altro'
			END AS Contratto,

			
			a.aziRagioneSociale as DenominazioneEnte,

			'NO' as SenzaImporto,

			--dbo.FormatMoney(ImportoBaseAsta2) AS a_base_asta,
			dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta,
			ImportoBaseAsta as a_base_asta_tec, 

			cast('' as varchar(100)) as di_aggiudicazione,

			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , DataInvio, 126)) as DtPubblicazione, 
			-- Data di pubblicazione. serve per il tag rss pubDate
			left(convert( VARCHAR(50) , DataInvio, 126), 19) as RECEIVEDDATAMSG,
			left(convert( VARCHAR(50) , DataInvio, 126), 19) as DataInvio,

			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126)) AS DtScadenzaBando ,
			convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126) AS DtScadenzaBandoTecnical ,
			NULL as DtScadenzaPubblEsito,
			'' as RequisitiQualificazione,

			'' as CPV,
			'' as SCP,
			'' as URL,
			CIG, 
			CASE WHEN richiestaquesito = 1  and dz.DZT_ValueDef='SI'
				THEN 'YES'
				ELSE 'NO'
			END AS RichiestaQuesito,
			CASE WHEN r.ID_MSG_BANDO IS NULL 
				THEN 0 
				ELSE 1 
			END AS bEsito
			, cast('SI' as varchar(50)) AS VisualizzaQuesiti
			, '' as direzioneespletante
				,ISNULL(Appalto_Verde,'no') as Appalto_Verde
			,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 

			,convert( VARCHAR(50) , DataInvio, 126) as DtPubblicazioneTecnical

			, a.aziProvinciaLeg AS Provincia 
			, a.aziLocalitaLeg AS Comune 
			, a.aziIndirizzoLeg

			-- 'Province' as TipoEnte

			, CASE isnull(viewTipoAmmin1.DMV_DescML,'') 
				WHEN '' THEN viewTipoAmmin2.dmv_descml
				ELSE viewTipoAmmin1.dmv_descml
				END AS TipoEnte 
				,case 
					when Appalto_Verde='si' and Acquisto_Sociale='si' then  '<span class="imgbandi"><img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png"></span>'  
					when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">' 
					when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png">' 
				 end as Bando_Verde_Sociale
			 
				, statoFunzionale
				, tipoDoc as tipoDocOriginal
				, isnull(descs.DMV_DescML, 'Altri Beni') as ambito

				,titolo as titoloDocumento

				, convert( VARCHAR(50) , DataChiusura, 126) as DataChiusuraTecnical 

				, ctl_doc.Fascicolo
				, ctl_doc.[Data] as dataCreazione
				
				--,dbo.GetDescStrutturaAziendale(EnteProponente) as EnteProponente
				, cast('' as nvarchar(max)) as EnteProponente
				, EnteProponente as CodEnteProponente
				, case when M.CodFisGest is null then 0 else 1 end as Gestore
				, ctl_doc.Protocollo as RegistroSistema
				, Merceologia
				, CTL_DOC.JUMPCHECK
					
		FROM ctl_doc with(nolock) 
			INNER JOIN aziende a with(nolock) on azienda = a.idazi
			INNER JOIN document_bando  with(nolock)  on id = idheader

			LEFT OUTER JOIN (
				select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito from Document_RisultatoDiGara with(nolock)	
					inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
					) as r on r.ID_MSG_BANDO = -CTL_DOC.id

				
			-- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
			INNER JOIN (
					SELECT dmv_descml, dmv_cod, DMV_CodExt from 
						lib_domainvalues  with(nolock) where dmv_dm_id = 'Tipologia'
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
							) AS viewTipoAmmin2 ON viewTipoAmmin2.dmv_cod = a.TipoDiAmministr

			--left  join (Select distinct(linkedDoc), deleted as cancellato from ctl_doc with(nolock) where tipodoc='PROROGA_GARA' and  statofunzionale = 'Inviato' and deleted = 0) V on V.LinkedDoc=CTL_DOC.id and V.cancellato = 0 
			--left  join (Select distinct(linkedDoc), deleted as cancellato from ctl_doc with(nolock) where tipodoc='RETTIFICA_GARA' and  statofunzionale = 'Inviato' and deleted = 0) Z on Z.LinkedDoc=CTL_DOC.id and Z.cancellato = 0
			left  join (
			
			
					select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
						inner join ( 
										Select max(id) as ID_DOC ,  linkedDoc from ctl_doc  with(nolock) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA'  ) and Statodoc ='Sended' group by linkedDoc  
										) as M on M.id_DOC = d.id
			
					) V on V.LinkedDoc=ctl_doc.id

			-- Dal codice del modello risalgo al suo ambito
			LEFT JOIN ctl_doc_value vals with(nolock) ON vals.idheader = ctl_doc.id and vals.DZT_Name = 'id_modello' and vals.dse_id = 'TESTATA_PRODOTTI'
			LEFT JOIN ctl_doc_value ambiti with(nolock) ON vals.value = ambiti.idheader and ambiti.DSE_ID = 'AMBITO' and ambiti.DZT_Name = 'MacroAreaMerc'
			LEFT JOIN LIB_DomainValues descs with(nolock) ON descs.DMV_Cod = ambiti.Value and descs.DMV_DM_ID = 'Ambito'
			LEFT JOIN LIB_Dictionary DZ with(nolock) on DZ.DZT_Name='SYS_INSERISCIQUESITIDALPORTALE'

			-- VALORIZZIAMO LA COLONNNA BOOLEAN "GESTORE" PER INDICARE CHE LA GARA E' STATA CREATA DA UN ENTE TRA LE AZIENDE CON IL CODICE FISCALE DELL'AZI MASTER ( 1..N )

			LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = a.IdAzi and cfs.dztNome = 'codicefiscale'

			LEFT JOIN (
						select distinct cfs.vatValore_FT as CodFisGest
							from marketplace m with(nolock) 
									LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = mpIdAziMaster and cfs.dztNome = 'codicefiscale'
					) as M on M.CodFisGest = cfs.vatValore_FT

		WHERE tipodoc = 'BANDO_SEMPLIFICATO' and statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato', 'NEW_SEMPLIFICATO') and deleted = 0

	UNION ALL   --- AGGIUNGO BANDO_GARA


		SELECT 
			ctl_doc.id as IdMsg, 
			'' as IdDoc, 
			1000 as msgIType, 
			221 as msgISubType, 
			TipoDoc as OPEN_DOC_NAME,
			IdPfu as IdMittente,
			0 as TipoAppalto,

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
			when  'Sospeso' then '<strong>Procedura Sospesa - </strong> ' + cast(Body as nvarchar (4000)) 
			when  'InSospensione' then '<strong>Procedura in Sospensione - </strong> ' + cast(Body as nvarchar (4000)) 
			else
				case 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  'RIPRISTINO_GARA' then '<strong>Procedura Ripristinata - </strong> ' + cast( Body as nvarchar(4000)) 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> 'RIPRISTINO_GARA' then  '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
				else
					cast( Body as nvarchar(4000)) 
				end		
			end as Oggetto, 

			--ritornare avviso se tipobandogara=1
			case 
				when tipobandogara in ('1','4','5') then 'Avviso'
				else 'Bando'
			end as Tipo, 

			CASE domVal.DMV_CodExt
					WHEN '15495' THEN 'Forniture'
					WHEN '15496' THEN 'Lavori'
					WHEN '15494' THEN 'Servizi'
					ELSE 'Altro'
			END AS Contratto,

			aziRagioneSociale as DenominazioneEnte,

			'NO' as SenzaImporto,

			--dbo.FormatMoney(ImportoBaseAsta2) AS a_base_asta,
			dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta,
			ImportoBaseAsta as a_base_asta_tec, 
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

			CASE WHEN RichiestaQuesito  <> '1' OR ( tipobandogara = '3' AND ProceduraGara = '15478' ) 
            
		  					THEN 'NO'

					ELSE CASE WHEN DataTermineQuesiti > GETDATE() and dz.DZT_ValueDef='SI' 
			         
							THEN 'YES'
			             
							ELSE CASE WHEN isnull(DataTermineQuesiti,'') = '' AND DataScadenzaOfferta > GETDATE() and dz.DZT_ValueDef='SI'
									THEN 'YES'
									ELSE 'NO'
								END
					END  
				END AS RichiestaQuesito,


			CASE WHEN r.ID_MSG_BANDO IS NULL 
				THEN 0 
				ELSE 1 
			END AS bEsito
			, CASE WHEN TIPOBANDOGARA <> '3' THEN 'SI' ELSE 'NO' END AS VisualizzaQuesiti
			, '' as direzioneespletante
			
			,ISNULL(Appalto_Verde,'no') as Appalto_Verde
			,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 	
			
			,convert( VARCHAR(50) , DataInvio, 126) as DtPubblicazioneTecnical
				
			, a.aziProvinciaLeg AS Provincia 
			, a.aziLocalitaLeg AS Comune 
			, a.aziIndirizzoLeg

			,  viewTipoAmmin2.dmv_descml as TipoEnte
			 
			,case 
					when Appalto_Verde='si' and Acquisto_Sociale='si' then  '<span class="imgbandi"><img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png"></span>'  
					when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">' 
					when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png">' 
			end as Bando_Verde_Sociale

			,statoFunzionale
			,tipoDoc as tipoDocOriginal

			, isnull(viewAmbito.DMV_DescML, 'Altri Beni') as ambito

			, titolo as titoloDocumento
			
			, convert( VARCHAR(50) , DataChiusura, 126) as DataChiusuraTecnical 

			, ctl_doc.Fascicolo
			, ctl_doc.[Data] as dataCreazione
			--,dbo.GetDescStrutturaAziendale(EnteProponente) as EnteProponente
			, cast('' as nvarchar(max)) as EnteProponente
			, EnteProponente as CodEnteProponente
			, case when M.CodFisGest is null then 0 else 1 end as Gestore
			, ctl_doc.Protocollo as RegistroSistema
			, Merceologia
			, CTL_DOC.JUMPCHECK

		FROM ctl_doc with(nolock) 
				LEFT JOIN ctl_doc_value vals with(nolock) ON vals.idheader = ctl_doc.id and vals.DZT_Name = 'ambito' and vals.dse_id = 'TESTATA_PRODOTTI'
				INNER JOIN aziende a with(nolock) on azienda = a.idazi
				INNER JOIN document_bando  with(nolock)  on id = document_bando.idheader

				LEFT OUTER JOIN (
					select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito 
						from Document_RisultatoDiGara with(nolock)	
							inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
						) as r on r.ID_MSG_BANDO = -CTL_DOC.id

				
				-- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
				INNER JOIN (
						SELECT dmv_descml, dmv_cod, DMV_CodExt from 
							lib_domainvalues  with(nolock) where dmv_dm_id = 'Tipologia'
						) as domVal on domVal.dmv_cod = Document_Bando.TipoAppaltoGara


				LEFT OUTER JOIN (
									SELECT dmv_descml, dmv_cod 
									FROM lib_domainvalues  with(nolock) 
									WHERE dmv_dm_id = 'TipoDiAmministr'

								) AS viewTipoAmmin2 ON viewTipoAmmin2.dmv_cod = a.TipoDiAmministr
				--left  join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='PROROGA_GARA' and statofunzionale = 'Inviato' and deleted = 0) V on V.LinkedDoc=CTL_DOC.id
				--left  join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='RETTIFICA_GARA' and statofunzionale = 'Inviato'  and deleted = 0) Z on Z.LinkedDoc=CTL_DOC.id
				left  join (
			
			
					select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
						inner join ( 
										Select max(id) as ID_DOC ,  linkedDoc from ctl_doc  with(nolock) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA'  ) and Statodoc ='Sended' group by linkedDoc  
										) as M on M.id_DOC = d.id
			
					) V on V.LinkedDoc=ctl_doc.id
				LEFT OUTER JOIN (
									SELECT dmv_descml, dmv_cod FROM
									lib_domainvalues  with(nolock) WHERE dmv_dm_id = 'ambito'
								) AS viewAmbito ON viewAmbito.dmv_cod = vals.value
				
				LEFT JOIN LIB_Dictionary DZ with(nolock) on DZ.DZT_Name='SYS_INSERISCIQUESITIDALPORTALE'

				-- VALORIZZIAMO LA COLONNNA BOOLEAN "GESTORE" PER INDICARE CHE LA GARA E' STATA CREATA DA UN ENTE TRA LE AZIENDE CON IL CODICE FISCALE DELL'AZI MASTER ( 1..N )
				LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = a.IdAzi and cfs.dztNome = 'codicefiscale'

				LEFT JOIN (
							select distinct cfs.vatValore_FT as CodFisGest
								from marketplace m with(nolock) 
										LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = mpIdAziMaster and cfs.dztNome = 'codicefiscale'
						) as M on M.CodFisGest = cfs.vatValore_FT

		WHERE tipodoc in ('BANDO_GARA','BANDO_CONCORSO') and statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato') and deleted = 0 and evidenzapubblica = '1'

	UNION ALL   --- AGGIUNGO gli esiti del BANDO_GARA e del BANDO_SEMPLIFICATO


			SELECT 
				gara.id as IdMsg, 
				'' as IdDoc, 
				1000 as msgIType, 
				221 as msgISubType, 
				gara.TipoDoc as OPEN_DOC_NAME,
				gara.IdPfu as IdMittente,
				0 as TipoAppalto,

				0 as bScaduto,

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
				case gara.statodoc 
					when 'Sended' then '2' 
					else '1' 
				end as StatoGD,
				cast( gara.Body as nvarchar(4000)) as Oggetto, 

				'Esito' as Tipo, 
				--domVal.dmv_descml as Contratto,

				CASE domVal.DMV_CodExt
						WHEN '15495' THEN 'Forniture'
						WHEN '15496' THEN 'Lavori'
						WHEN '15494' THEN 'Servizi'
						ELSE 'Altro'
				END AS Contratto,

				aziRagioneSociale as DenominazioneEnte,

				'NO' as SenzaImporto,

				--dbo.FormatMoney(ImportoBaseAsta2) AS a_base_asta,
				dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta,
				ImportoBaseAsta as a_base_asta_tec, 

				'' as di_aggiudicazione,

				dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , isnull(r.DataPubbEsito,gara.DataInvio ), 126)) as DtPubblicazione, 

				-- Data di pubblicazione. serve per il tag rss pubDate
				left(convert( VARCHAR(50) ,  isnull(r.DataPubbEsito,r.datacreazione), 126),19) as RECEIVEDDATAMSG,
				left(convert( VARCHAR(50) , isnull(r.DataPubbEsito,r.datacreazione), 126),19) as DataInvio,

				dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126)) AS DtScadenzaBando ,
				convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126) AS DtScadenzaBandoTecnical 

				   , r.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
					  , '' AS RequisitiQualificazione
					  , '' AS CPV
					  , r.CodSCP AS SCP
					  , r.UrlSCP AS URL

					,CIG, 
				CASE WHEN richiestaquesito = 1 and dz.DZT_ValueDef='SI'
					THEN 'YES'
					ELSE 'NO'
				END AS RichiestaQuesito,
				CASE WHEN r.ID_MSG_BANDO IS NULL 
					THEN 0 
					ELSE 1 
				END AS bEsito
				, 'SI' AS VisualizzaQuesiti
				, '' as direzioneespletante
			
				,ISNULL(Appalto_Verde,'no') as Appalto_Verde
				,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 

				,convert( VARCHAR(50) , isnull(r.DataPubbEsito,gara.DataInvio ), 126) as DtPubblicazioneTecnical

				, a.aziProvinciaLeg AS Provincia 
				, a.aziLocalitaLeg AS Comune 
				, a.aziIndirizzoLeg

				,  viewTipoAmmin2.dmv_descml as TipoEnte
			 
				,case 
						when Appalto_Verde='si' and Acquisto_Sociale='si' then  '<span class="imgbandi"><img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png"></span>'  
						when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="./images/Appalto_Verde.png">' 
						when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="./images/Acquisto_Sociale.png">' 
				end as Bando_Verde_Sociale

				, gara.statoFunzionale
				, gara.tipoDoc as tipoDocOriginal
				, isnull(viewAmbito.DMV_DescML, 'Altri Beni') as ambito

				, gara.titolo as titoloDocumento
			
				, convert( VARCHAR(50) , DataChiusura, 126) as DataChiusuraTecnical 

				, gara.Fascicolo
				, gara.[Data] as dataCreazione
				--,dbo.GetDescStrutturaAziendale(EnteProponente) as EnteProponente
				, cast('' as nvarchar(max)) as EnteProponente
				, EnteProponente as CodEnteProponente
				, case when M.CodFisGest is null then 0 else 1 end as Gestore
				, esito.Protocollo as RegistroSistema
				, Merceologia
				, gara.JUMPCHECK

			FROM ctl_doc gara with(nolock) 
				LEFT JOIN ctl_doc_value vals with(nolock) ON vals.idheader = gara.id and vals.DZT_Name = 'ambito' and vals.dse_id = 'TESTATA_PRODOTTI'
				INNER JOIN aziende a with(nolock) on azienda = a.idazi
				INNER JOIN document_bando  with(nolock) on gara.id = document_bando.idheader

				INNER JOIN (
					select 
						distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito 
						   , DataPubbEsito
						   , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
								, CodSCP
								, UrlSCP
						   , datacreazione
						from Document_RisultatoDiGara with(nolock)	
								inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
						) as r on r.ID_MSG_BANDO = -gara.id
				
				LEFT JOIN ctl_doc esito with(nolock) ON esito.LinkedDoc = gara.Id and esito.TipoDoc = 'NEW_RISULTATODIGARA' 
														and esito.Deleted = 0 and esito.StatoFunzionale = 'Inviato'
				inner join ctl_doc_value CV with(nolock) on esito.id=CV.IdHeader and CV.DSE_ID='TESTATA' and CV.DZT_Name='TipoDocumentoEsito' and CV.Value='Esito'
				-- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
				INNER JOIN (
					
						SELECT dmv_descml, dmv_cod, DMV_CodExt 
							from lib_domainvalues  with(nolock) where dmv_dm_id = 'Tipologia'

					 ) as domVal on domVal.dmv_cod = Document_Bando.TipoAppaltoGara

				LEFT OUTER JOIN (
								  SELECT dmv_descml, dmv_cod 
									FROM lib_domainvalues  with(nolock) WHERE dmv_dm_id = 'TipoDiAmministr'

								) AS viewTipoAmmin2 ON viewTipoAmmin2.dmv_cod = a.TipoDiAmministr

				LEFT OUTER JOIN (
								  SELECT dmv_descml, dmv_cod 
									FROM lib_domainvalues  with(nolock) WHERE dmv_dm_id = 'ambito'

								) AS viewAmbito ON viewAmbito.dmv_cod = vals.value
			
				LEFT JOIN LIB_Dictionary DZ with(nolock) on DZ.DZT_Name='SYS_INSERISCIQUESITIDALPORTALE'

				-- VALORIZZIAMO LA COLONNNA BOOLEAN "GESTORE" PER INDICARE CHE LA GARA E' STATA CREATA DA UN ENTE TRA LE AZIENDE CON IL CODICE FISCALE DELL'AZI MASTER ( 1..N )

				LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = a.IdAzi and cfs.dztNome = 'codicefiscale'

				LEFT JOIN (
							select distinct cfs.vatValore_FT as CodFisGest
								from marketplace m with(nolock) 
										LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = mpIdAziMaster and cfs.dztNome = 'codicefiscale'
						) as M on M.CodFisGest = cfs.vatValore_FT

			WHERE gara.tipodoc in (  'BANDO_GARA', 'BANDO_SEMPLIFICATO', 'BANDO_CONCORSO') and gara.statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato','NEW_SEMPLIFICATO') and gara.deleted = 0 and evidenzapubblica = '1'

	) PORTALE

		LEFT JOIN (	select fascicolo, max(datainvio) as ultimaModifica from CTL_DOC x with(nolock) where x.Deleted = 0 and x.DataInvio is not null and isnull(fascicolo,'') <> '' group by fascicolo ) fascicolo ON fascicolo.Fascicolo = portale.Fascicolo



GO
