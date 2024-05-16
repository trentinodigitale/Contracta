USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SIMOG_LOTTO_DATI_WS]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[OLD_SIMOG_LOTTO_DATI_WS] AS
	select    req.idRow as idService -- chiave
			, pfu.pfuCodiceFiscale as [LOGIN]
			--, 'BRTLSE81P57C265Z' as [LOGIN]
			, dbo.DecryptPwd(pfuA.attValue) as [PASSWORD]
			--, 'PAssw0rd.1' as [PASSWORD]
			, dm1.vatValore_FT as CF_ENTE
			, lot.NumeroLotto
			, left ( lot.OGGETTO, 1024 ) as OGGETTO
			, lot.SOMMA_URGENZA
			, lot.IMPORTO_LOTTO
			, lot.IMPORTO_SA
			, lot.IMPORTO_IMPRESA
			, isnull(cpv.DMV_CodExt,lot.CPV) as CPV
			--, lot.ID_SCELTA_CONTRAENTE
			, gara.ID_SCELTA_CONTRAENTE
			, lot.ID_CATEGORIA_PREVALENTE
			, lot.TIPO_CONTRATTO
			, lot.FLAG_ESCLUSO
			--, lot.LUOGO_ISTAT
			, case when geo.DMV_Level = 7 then RIGHT( '0000' + dbo.GetColumnValue( lot.LUOGO_ISTAT,'-', 8), 6) else '' end as LUOGO_ISTAT -- Se si è selezionato un nodo di livello comune / 7 prendo il codice istat dalla sua ultima parte dmv_cod
			,   case when geo.DMV_Level = 6 then dbo.GetColumnValue( lot.LUOGO_ISTAT,'-', 7)	-- se si è scelto una provincia prendo il suo codice NUTS
					 when geo.DMV_Level = 5 then dbo.GetColumnValue( lot.LUOGO_ISTAT,'-', 6)	-- se si è scelta una regione prendo il suo codice NUTS
					 else '' 
				end as CODICE_NUTS
			, ISNULL(lot.IMPORTO_ATTUAZIONE_SICUREZZA,0) as IMPORTO_ATTUAZIONE_SICUREZZA
			, lot.FLAG_PREVEDE_RIP
			, lot.FLAG_RIPETIZIONE
			, lot.FLAG_CUP
			, lot.CATEGORIA_SIMOG as CATEGORIE_MERC
			, lot.EsitoControlli
			, lot.StatoRichiestaLOTTO
			, lot.CIG

			, gara.indexCollaborazione as [INDEX]
			, gara.id_gara as ID_GARA
			, left(isnull(lot.note_canc,doc.Note),1000) as NOTE_CANC -- motivazione cancellazione lotto
			, isnull( doc.Versione,'') as versioneSimog 
			, lot.MOTIVO_CANCELLAZIONE_LOTTO as id_motivazione

			, gara.idpfuRup

			-- nuovi campi per versione simog 3.4.2
			, lot.MODALITA_ACQUISIZIONE 
			, lot.Condizioni
			, lot.TIPOLOGIA_LAVORO 
			, lot.ID_ESCLUSIONE
			, lot.ID_AFF_RISERVATI
			, lot.FLAG_REGIME 
			, lot.ART_REGIME 
			, lot.FLAG_DL50 
			, lot.PRIMA_ANNUALITA 
			, lot.ANNUALE_CUI_MININF

			-- nuovi campi per versione simog 3.4.3
			, lot.ID_MOTIVO_COLL_CIG
			, lot.CIG_ORIGINE_RIP

			-- nuovi campi per versione simog 3.4.4
			, gara.CATEGORIE_MERC as CATEGORIA_MERC

			--dato aggiunto per errore 'SIMOG_VALIDAZIONE_125 - Codici CUP: Il campo e' obbligatorio'
			, isnull( lot.CUP , isnull(ban.CUP,'') ) as CUP

			-- nuovi campi per la versione 3.4.5
			, isnull(lot.IMPORTO_OPZIONI, 0) as IMPORTO_OPZIONI

			-- nuovi campi versione 3.4.6
			, isnull(lot.DURATA_ACCQUADRO_CONVENZIONE,0) as DURATA_AFFIDAMENTO
			, isnull(lot.DURATA_RINNOVI,0) as DURATA_RINNOVI 

			-- nuovi campi simog V. 3.04.7
			, isnull(lot.FLAG_PNRR_PNC,'') as FLAG_PNRR_PNC
			, isnull(lot.ID_MOTIVO_DEROGA,'') as ID_MOTIVO_DEROGA
			, isnull(lot.FLAG_MISURE_PREMIALI,'') as FLAG_MISURE_PREMIALI
			, isnull(lot.ID_MISURA_PREMIALE,'') as ID_MISURA_PREMIALE
			, isnull(lot.FLAG_PREVISIONE_QUOTA,'') as FLAG_PREVISIONE_QUOTA
			, isnull(lot.QUOTA_FEMMINILE,'') as QUOTA_FEMMINILE
			, isnull(lot.QUOTA_GIOVANILE,'') as QUOTA_GIOVANILE

			-- nuovi campi simog V. 3.04.8.1
			, ISNULL(lot.FLAG_USO_METODI_EDILIZIA, '') as FLAG_USO_METODI_EDILIZIA
			, ISNULL(lot.FLAG_DEROGA_ADESIONE, '') as FLAG_DEROGA_ADESIONE
			, ISNULL(lot.DEROGA_QUALIFICAZIONE_SA, '') as DEROGA_QUALIFICAZIONE_SA
			,bando.TipoDoc as TipoDoc_collegato
			

		from Service_SIMOG_Requests req				with(nolock)
				inner join Document_SIMOG_LOTTI lot with(nolock) on lot.idrow = req.idRichiesta
				inner join ctl_doc doc				with(nolock) on doc.id = lot.idHeader and doc.TipoDoc IN ( 'RICHIESTA_CIG', 'ANNULLA_RICHIESTA_CIG' )
				left join document_bando ban		with(nolock) on ban.idHeader = doc.LinkedDoc
				inner join Document_SIMOG_GARA gara with(nolock) on gara.idHeader = doc.Id
				inner join ProfiliUtente pfu		with(nolock) on pfu.IdPfu = gara.idpfuRup
				left  join ProfiliUtenteAttrib pfuA	with(nolock) on pfuA.IdPfu = gara.idpfuRup and pfuA.dztNome = 'simog_password'
				inner join aziende ente				with(nolock) on ente.idazi = pfu.pfuIdAzi
				inner join DM_Attributi dm1			with(nolock) on dm1.lnk = ente.IdAzi and dm1.dztNome = 'codicefiscale'
				left join LIB_DomainValues cpv		with(nolock) on cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = lot.CPV
				left join LIB_DomainValues geo		with(nolock) on geo.DMV_DM_ID = 'GEO' and geo.DMV_Cod = lot.LUOGO_ISTAT
				left join ctl_doc bando with(nolock) on bando.id=doc.LinkedDoc
GO
