USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_SIMOG_LOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[Document_SIMOG_LOTTI_VIEW] as 

	select 
			g.idRow, g.idHeader, [NumeroLotto], [OGGETTO], [SOMMA_URGENZA], [IMPORTO_LOTTO], [IMPORTO_SA], [IMPORTO_IMPRESA], g.[CPV], [ID_SCELTA_CONTRAENTE], [ID_CATEGORIA_PREVALENTE], [TIPO_CONTRATTO], [FLAG_ESCLUSO], [LUOGO_ISTAT], [IMPORTO_ATTUAZIONE_SICUREZZA], [FLAG_PREVEDE_RIP], [FLAG_RIPETIZIONE], [FLAG_CUP], [CATEGORIA_SIMOG], 
			 
			 g.ID_ESCLUSIONE, g.Condizioni, g.ID_AFF_RISERVATI, g.FLAG_REGIME, g.ART_REGIME, g.FLAG_DL50, g.PRIMA_ANNUALITA, 
			 g.ANNUALE_CUI_MININF, g.ID_MOTIVO_COLL_CIG, g.CIG_ORIGINE_RIP, g.IMPORTO_OPZIONI, g.FLAG_DEROGA_ADESIONE, g.FLAG_USO_METODI_EDILIZIA, g.DEROGA_QUALIFICAZIONE_SA

			 --dato aggiunto per errore 'SIMOG_VALIDAZIONE_125 - Codici CUP: Il campo e' obbligatorio'
			, isnull ( g.CUP ,  isnull(ban.CUP,'') )  as CUP,

			 case 
			 	--when ( r.idrow is null or isnull(msgError,'') = '' ) and [EsitoControlli] <> '' then [EsitoControlli] 
			 	--when ( r.idrow is null or isnull(msgError,'') = '' ) and [EsitoControlli] = '' then '<img src="../images/Domain/State_OK.gif">' 

				when isnull(msgError,'') = ' --- OK' or isnull(msgError,'') = '' and [EsitoControlli] <> '' then [EsitoControlli] 
				when isnull(msgError,'') = ' --- OK' or isnull(msgError,'') = '' and [EsitoControlli] = '' then '<img src="../images/Domain/State_OK.gif">' 
			  	else replace([EsitoControlli],'<img src="../images/Domain/State_OK.gif">','') + '<br><br><img src="../images/Domain/State_ERR.gif"><br>' + isnull(msgError,'') 

			 end as [EsitoControlli], 

			r.StatoRichiesta as [StatoRichiestaLOTTO], g.[CIG] , 
			[note_canc],[MOTIVO_CANCELLAZIONE_LOTTO],[AzioneProposta],
			r.isOld,
			MODALITA_ACQUISIZIONE,TIPOLOGIA_LAVORO,
			g.DURATA_ACCQUADRO_CONVENZIONE,
			g.DURATA_RINNOVI,

			case 

				when -- se il lotto è editabile ed è variazione o inserisci tutto editabile tranne i campi per la cancellazione
						isnull( r.StatoRichiesta , '' )  in ( '' , 'Errore' ) 
						and g.AzioneProposta <> 'Delete' 
						--se non già presente lo aggiungo altrimenti il nuovo valore viene aggiunto sempre ed aumenta
						--il contenuto ad ogni salvataggio
						and CHARINDEX ( ' MOTIVO_CANCELLAZIONE_LOTTO note_canc ' , isnull(g.NotEditable,'')  ) = 0
					then ' MOTIVO_CANCELLAZIONE_LOTTO note_canc '
					
				when -- se il lotto è editabile ed è Cancella editabile solo i campi per la cancellazione
						isnull( r.StatoRichiesta , '' )  in ( '' , 'Errore' ) 
						and g.AzioneProposta = 'Delete' 
						--se non già presente lo aggiungo altrimenti il nuovo valore viene aggiunto sempre ed aumenta
						--il contenuto ad ogni salvataggio
						and CHARINDEX ( ' SOMMA_URGENZA IMPORTO_LOTTO IMPORTO_SA IMPORTO_IMPRESA CPV ID_SCELTA_CONTRAENTE ID_CATEGORIA_PREVALENTE TIPO_CONTRATTO  FLAG_ESCLUSO LUOGO_ISTAT IMPORTO_ATTUAZIONE_SICUREZZA FLAG_PREVEDE_RIP FLAG_RIPETIZIONE FLAG_CUP CATEGORIA_SIMOG MODALITA_ACQUISIZIONE TIPOLOGIA_LAVORO ID_ESCLUSIONE ID_AFF_RISERVATI FLAG_REGIME ART_REGIME FLAG_DL50 PRIMA_ANNUALITA ANNUALE_CUI_MININF ID_MOTIVO_COLL_CIG CIG_ORIGINE_RIP IMPORTO_OPZIONI '  , isnull(g.NotEditable,'') ) = 0
					then ' SOMMA_URGENZA IMPORTO_LOTTO IMPORTO_SA IMPORTO_IMPRESA CPV ID_SCELTA_CONTRAENTE ID_CATEGORIA_PREVALENTE TIPO_CONTRATTO  FLAG_ESCLUSO LUOGO_ISTAT IMPORTO_ATTUAZIONE_SICUREZZA FLAG_PREVEDE_RIP FLAG_RIPETIZIONE FLAG_CUP CATEGORIA_SIMOG MODALITA_ACQUISIZIONE TIPOLOGIA_LAVORO ID_ESCLUSIONE ID_AFF_RISERVATI FLAG_REGIME ART_REGIME FLAG_DL50 PRIMA_ANNUALITA ANNUALE_CUI_MININF ID_MOTIVO_COLL_CIG CIG_ORIGINE_RIP IMPORTO_OPZIONI '
				

				else '' + case when ro.IdRow <> '' and CHARINDEX ( ' ID_MOTIVO_COLL_CIG ' , isnull(g.NotEditable,'')  ) = 0 then ' ID_MOTIVO_COLL_CIG ' else '' end

			end + isnull(g.NotEditable,'') as NotEditable

			-- nuovi campi simog V. 3.04.7
			, g.FLAG_PNRR_PNC
			, g.ID_MOTIVO_DEROGA
			, g.FLAG_MISURE_PREMIALI
			, g.ID_MISURA_PREMIALE
			, g.FLAG_PREVISIONE_QUOTA
			, g.QUOTA_FEMMINILE
			, g.QUOTA_GIOVANILE
	 
	 
		 from [dbo].[Document_SIMOG_LOTTI] g with(nolock)
			left outer join Service_SIMOG_Requests r with(nolock) on g.idrow = r.idRichiesta and r.operazioneRichiesta in ( 'lottoinserisci' , 'lottocancella' , 'lottomodifica' )  and r.isOld = 0 
			inner join CTL_DOC d with(nolock) on d.id = g.idheader
			left join document_bando ban with(nolock) on ban.idHeader = d.LinkedDoc
			LEFT JOIN  CTL_DOC_VALUE ro with(nolock) ON ro.IdHeader = d.Id and ro.dse_id = 'LAVORO' and ro.DZT_Name = 'BLOCCA_MOTIVO_COLLEGAMENTO'
GO
