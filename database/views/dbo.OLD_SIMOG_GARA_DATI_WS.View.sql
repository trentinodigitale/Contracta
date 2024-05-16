USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SIMOG_GARA_DATI_WS]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_SIMOG_GARA_DATI_WS] AS
	select    req.idRow as idService -- chiave
			, pfu.pfuCodiceFiscale as [LOGIN]
			--, 'BRTLSE81P57C265Z' as [LOGIN]
			, dbo.DecryptPwd(pfuA.attValue) as [PASSWORD]
			--, 'PAssw0rd.1' as [PASSWORD]
			, left ( cast(doc.Body as nvarchar(max)), 1024 ) as OGGETTO
			, isnull( doc.Versione,'') as versioneSimog 
			, gara.ID_STAZIONE_APPALTANTE
			, gara.DENOM_STAZIONE_APPALTANTE
			, gara.CF_AMMINISTRAZIONE
			, gara.DENOM_AMMINISTRAZIONE
			, gara.CF_UTENTE
			, gara.IMPORTO_GARA
			, gara.TIPO_SCHEDA
			, gara.MODO_REALIZZAZIONE
			, gara.NUMERO_LOTTI
			, gara.ESCLUSO_AVCPASS
			, gara.URGENZA_DL133
			, gara.CATEGORIE_MERC
			, gara.id_gara as ID_GARA
			, dm1.vatValore_FT as CF_ENTE
			, gara.MOTIVAZIONE_CIG

			, doc.Note as NOTE_CANC -- motivazione cancellazione gara
			, gara.MOTIVO_CANCELLAZIONE_GARA as id_motivazione

			, gara.idpfuRup
			, gara.indexCollaborazione as [INDEX]

			-- campi nuova versione simog 3.4.2
			, isnull(gara.STRUMENTO_SVOLGIMENTO,'') as STRUMENTO_SVOLGIMENTO
			, isnull(gara.ESTREMA_URGENZA ,'') as ESTREMA_URGENZA
			, isnull(gara.MODO_INDIZIONE, '') as MODO_INDIZIONE

			-- nuove colonne per versione simog 3.4.3
			, isnull(gara.ALLEGATO_IX,'') as ALLEGATO_IX
			, isnull(gara.DURATA_ACCQUADRO_CONVENZIONE,'') as DURATA_ACCQUADRO_CONVENZIONE
			, isnull(gara.CIG_ACC_QUADRO,'') as CIG_ACC_QUADRO
			, ISNULL(dv1.value, '') as StazioneAppaltanteSoggettoSingolo
			, ISNULL(dv2.value, '') as DenominazioneAmministrazioneSA
			, ISNULL(dv3.value, '') as CodiceFiscaleSoggettoSA
			, ISNULL(dv4.value, '') as FUNZIONI_DELEGATE
			,bando.TipoDoc as TipoDoc_collegato
		from Service_SIMOG_Requests req				with(nolock)
				inner join Document_SIMOG_GARA gara with(nolock) on gara.idrow = req.idRichiesta
				inner join ProfiliUtente pfu		with(nolock) on pfu.IdPfu = gara.idpfuRup
				left  join ProfiliUtenteAttrib pfuA	with(nolock) on pfuA.IdPfu = gara.idpfuRup and pfuA.dztNome = 'simog_password'
				inner join aziende ente				with(nolock) on ente.idazi = pfu.pfuIdAzi
				inner join DM_Attributi dm1			with(nolock) on dm1.lnk = ente.IdAzi and dm1.dztNome = 'codicefiscale'
				inner join ctl_doc doc				with(nolock) on doc.id = gara.idHeader and doc.TipoDoc IN ( 'RICHIESTA_CIG', 'ANNULLA_RICHIESTA_CIG' )
				left join CTL_DOC_Value dv1		with(nolock) on doc.Id = dv1.IdHeader and dv1.DSE_ID = 'GARADELEGA' and dv1.DZT_Name = 'StazioneAppaltanteSoggettoSingolo'
				left join CTL_DOC_Value dv2		with(nolock) on doc.Id = dv2.IdHeader and dv2.DSE_ID = 'GARADELEGA' and dv2.DZT_Name = 'DenominazioneAmministrazioneSA'
				left join CTL_DOC_Value dv3		with(nolock) on doc.Id = dv3.IdHeader and dv3.DSE_ID = 'GARADELEGA' and dv3.DZT_Name = 'CodiceFiscaleSoggettoSA'
				left join CTL_DOC_Value dv4		with(nolock) on doc.Id = dv4.IdHeader and dv4.DSE_ID = 'GARADELEGA' and dv4.DZT_Name = 'FUNZIONI_DELEGATE'
				left join ctl_doc bando with(nolock) on bando.id=doc.LinkedDoc
GO
