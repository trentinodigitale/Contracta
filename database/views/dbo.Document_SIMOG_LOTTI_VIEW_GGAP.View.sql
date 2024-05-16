USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_SIMOG_LOTTI_VIEW_GGAP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_SIMOG_LOTTI_VIEW_GGAP]
AS
SELECT L.idRow
	   , L.idHeader
	   , NumeroLotto
	   , OGGETTO
	   , SOMMA_URGENZA
	   , IMPORTO_LOTTO
	   , IMPORTO_SA
	   , IMPORTO_IMPRESA
	   , L.CPV
	   , ID_SCELTA_CONTRAENTE
	   , ID_CATEGORIA_PREVALENTE
	   , TIPO_CONTRATTO
	   , FLAG_ESCLUSO
	   , LUOGO_ISTAT
	   , IMPORTO_ATTUAZIONE_SICUREZZA
	   , FLAG_PREVEDE_RIP
	   , FLAG_RIPETIZIONE
	   , FLAG_CUP
	   , CATEGORIA_SIMOG
	   , L.ID_ESCLUSIONE
	   , L.Condizioni
	   , L.ID_AFF_RISERVATI
	   , L.FLAG_REGIME
	   , L.ART_REGIME
	   , L.FLAG_DL50
	   , L.PRIMA_ANNUALITA
	   , L.ANNUALE_CUI_MININF
	   , L.ID_MOTIVO_COLL_CIG
	   , L.CIG_ORIGINE_RIP
	   , L.IMPORTO_OPZIONI
	   , L.FLAG_DEROGA_ADESIONE
	   , L.FLAG_USO_METODI_EDILIZIA
	   , L.DEROGA_QUALIFICAZIONE_SA

	   --dato aggiunto per errore 'SIMOG_VALIDAZIONE_125 - Codici CUP: Il campo e' obbligatorio'
	   , ISNULL(L.CUP, ISNULL(BANDO.CUP, '')) AS CUP

	   , CASE 
	   	    --when ( R.idrow is null or isnull(msgError,'') = '' ) and EsitoControlli <> '' then EsitoControlli 
	   	    --when ( R.idrow is null or isnull(msgError,'') = '' ) and EsitoControlli = '' then '<img src="../images/Domain/State_OK.gif">' 
	   	    WHEN (ISNULL(R.msgError, '') = ' --- OK' OR ISNULL(R.msgError, '') = '') AND L.EsitoControlli <> '' THEN L.EsitoControlli
	   	    WHEN (ISNULL(R.msgError, '') = ' --- OK' OR ISNULL(R.msgError, '') = '') AND L.EsitoControlli = '' THEN '<img src="../images/Domain/State_OK.gif">'
            WHEN R.msgError LIKE '% --- OK%' THEN '<img src="../images/Domain/State_OK.gif">'
	   	    --ELSE REPLACE(L.EsitoControlli, '<img src="../images/Domain/State_OK.gif">', '') + '<img src="../images/Domain/State_ERR.gif"><br>' + ISNULL(R.msgError, '')
	   	    ELSE REPLACE(L.EsitoControlli, '<img src="../images/Domain/State_OK.gif">', '') + '<img src="../images/Domain/State_ERR.gif"><br>' + ISNULL(R.msgError, '')
	   	 END AS EsitoControlli

	   , R.StatoRichiesta AS StatoRichiestaLOTTO_InSimogRequest

       , L.StatoRichiestaLOTTO
       , L.StatoRichiestaLOTTO AS StatoRichiestaLottoGgap

	   , L.CIG
	   , note_canc
	   , MOTIVO_CANCELLAZIONE_LOTTO
	   , AzioneProposta
	   , R.isOld
	   , MODALITA_ACQUISIZIONE
	   , TIPOLOGIA_LAVORO
	   , L.DURATA_ACCQUADRO_CONVENZIONE
	   , L.DURATA_RINNOVI

	   , CASE 
            -- se il lotto è editabile ed è variazione o inserisci tutto editabile tranne i campi per la cancellazione
	   	    WHEN ISNULL(R.StatoRichiesta, '') IN ('', 'Errore') AND L.AzioneProposta <> 'Delete'
	   	    	    --se non già presente lo aggiungo altrimenti il nuovo valore viene aggiunto sempre ed aumenta
	   	    	    --il contenuto ad ogni salvataggio
	   	    	    AND CHARINDEX(' MOTIVO_CANCELLAZIONE_LOTTO note_canc ', ISNULL(L.NotEditable, '')) = 0
	   	    	THEN ' MOTIVO_CANCELLAZIONE_LOTTO note_canc '
            -- se il lotto è editabile ed è Cancella editabile solo i campi per la cancellazione
	   	    WHEN ISNULL(R.StatoRichiesta, '') IN ('', 'Errore')AND L.AzioneProposta = 'Delete'
	   	    	    --se non già presente lo aggiungo altrimenti il nuovo valore viene aggiunto sempre ed aumenta
	   	    	    --il contenuto ad ogni salvataggio
	   	    	    AND CHARINDEX(' SOMMA_URGENZA IMPORTO_LOTTO IMPORTO_SA IMPORTO_IMPRESA CPV ID_SCELTA_CONTRAENTE ID_CATEGORIA_PREVALENTE TIPO_CONTRATTO  FLAG_ESCLUSO LUOGO_ISTAT IMPORTO_ATTUAZIONE_SICUREZZA FLAG_PREVEDE_RIP FLAG_RIPETIZIONE FLAG_CUP CATEGORIA_SIMOG MODALITA_ACQUISIZIONE TIPOLOGIA_LAVORO ID_ESCLUSIONE ID_AFF_RISERVATI FLAG_REGIME ART_REGIME FLAG_DL50 PRIMA_ANNUALITA ANNUALE_CUI_MININF ID_MOTIVO_COLL_CIG CIG_ORIGINE_RIP IMPORTO_OPZIONI ', isnull(L.NotEditable, '')) = 0
	   	    	THEN ' SOMMA_URGENZA IMPORTO_LOTTO IMPORTO_SA IMPORTO_IMPRESA CPV ID_SCELTA_CONTRAENTE ID_CATEGORIA_PREVALENTE TIPO_CONTRATTO  FLAG_ESCLUSO LUOGO_ISTAT IMPORTO_ATTUAZIONE_SICUREZZA FLAG_PREVEDE_RIP FLAG_RIPETIZIONE FLAG_CUP CATEGORIA_SIMOG MODALITA_ACQUISIZIONE TIPOLOGIA_LAVORO ID_ESCLUSIONE ID_AFF_RISERVATI FLAG_REGIME ART_REGIME FLAG_DL50 PRIMA_ANNUALITA ANNUALE_CUI_MININF ID_MOTIVO_COLL_CIG CIG_ORIGINE_RIP IMPORTO_OPZIONI '
	   	    --ELSE '' + CASE
         --               WHEN RO.IdRow <> '' AND CHARINDEX(' ID_MOTIVO_COLL_CIG ', isnull(L.NotEditable, '')) = 0 THEN ' ID_MOTIVO_COLL_CIG '
	   	    --		    ELSE ''
	   	    --		  END
	   	 END + ISNULL(L.NotEditable, '') AS NotEditable

	   -- nuovi campi simog V. 3.04.7
	   , L.FLAG_PNRR_PNC
	   , L.ID_MOTIVO_DEROGA
	   , L.FLAG_MISURE_PREMIALI
	   , L.ID_MISURA_PREMIALE
	   , L.FLAG_PREVISIONE_QUOTA
	   , L.QUOTA_FEMMINILE
	   , L.QUOTA_GIOVANILE

FROM [dbo].Document_SIMOG_LOTTI L WITH (NOLOCK)
            LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                                ON L.idrow = R.idRichiesta
            	                    AND R.operazioneRichiesta IN ('lottoInserisciGgap', 'lottoModificaGgap') -- , 'lottoinserisci', 'lottocancella', 'lottomodifica')
            	                    --AND R.isOld = 0
            INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = L.idheader
            LEFT JOIN document_bando BANDO WITH (NOLOCK) ON BANDO.idHeader = D.LinkedDoc
            --LEFT JOIN CTL_DOC_VALUE RO WITH (NOLOCK)
            --    ON RO.IdHeader = D.Id
            --	    AND RO.dse_id = 'LAVORO'
            --	    AND RO.DZT_Name = 'BLOCCA_MOTIVO_COLLEGAMENTO'
GO
