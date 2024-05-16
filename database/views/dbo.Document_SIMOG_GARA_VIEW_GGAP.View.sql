USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_SIMOG_GARA_VIEW_GGAP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_SIMOG_GARA_VIEW_GGAP]
AS
    SELECT G.idrow
    	, G.idHeader
    	, indexCollaborazione
    	, ID_STAZIONE_APPALTANTE
    	, DENOM_STAZIONE_APPALTANTE
    	, CF_AMMINISTRAZIONE
    	, DENOM_AMMINISTRAZIONE
    	, CF_UTENTE
    	, IMPORTO_GARA
    	, TIPO_SCHEDA
    	, MODO_REALIZZAZIONE
    	, NUMERO_LOTTI
    	, ESCLUSO_AVCPASS
    	, URGENZA_DL133
    	, G.CATEGORIE_MERC
    	, ID_SCELTA_CONTRAENTE

    	--, R.StatoRichiesta AS StatoRichiestaGARA
    	, G.StatoRichiestaGARA AS StatoRichiestaGaraGgap

        --, G.EsitoControlli
        --, R.idrow
    	, CASE 
    		WHEN R.idrow IS NULL THEN G.EsitoControlli
    		--ELSE replace(isnull(msgError, ''), ' --- OK', '')
    		WHEN R.msgError IS NULL THEN '' -- REPLACE(ISNULL(R.msgError, 'OK'), 'OK', '<img src="../images/Domain/State_OK.gif">')
    		WHEN R.msgError = '' THEN '' --REPLACE(R.msgError, '', '<img src="../images/Domain/State_OK.gif">')
            WHEN R.msgError LIKE '% --- OK%' THEN '<img src="../images/Domain/State_OK.gif">'
    		--ELSE msgError
    		--ELSE '<img src="../images/Domain/State_ERR.gif"><br>' + R.msgError
            ELSE G.EsitoControlli
    	  END AS EsitoControlli
        --, msgError

    	, id_gara
    	, G.idpfuRup
    	, R.idrow AS ID_RICHIESTA
    	, G.idHeader AS id
    	, MOTIVAZIONE_CIG
    	, MOTIVO_CANCELLAZIONE_GARA
    	, AzioneProposta
    	, D.StatoFunzionale
    	, R.isOld
    	, DB.TipoAppaltoGara
    	, BANDO.TipoDoc AS TipoDoc_collegato -- controllato lato JS,  se è un bando_semplificato chiediamo conferma al cambio di scelta del contraente
    	
        -- nuove colonne per versione simog 3.4.2
    	, G.STRUMENTO_SVOLGIMENTO
    	, G.ESTREMA_URGENZA
    	, G.MODO_INDIZIONE

    	-- nuove colonne per versione simog 3.4.3
    	, G.ALLEGATO_IX
    	, G.DURATA_ACCQUADRO_CONVENZIONE
    	, G.CIG_ACC_QUADRO

    	, ISNULL(G.NotEditable, '') AS NotEditable
    	, G.link_affidamento_diretto

        --, R.dateIn AS simogRequest_DateIn
        --, D.Data AS ctlDoc_Data
        --, DB.dataCreazione AS documentBando_dataCreazione

    FROM Document_SIMOG_GARA G WITH (NOLOCK)
            LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                ON G.idrow = R.idRichiesta
                    AND R.operazioneRichiesta IN ('garaInserisciGgap', 'garaModificaGgap') --'lottoInserisciGgap')
                    --AND R.isOld = 0
            INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = G.idHeader
            INNER JOIN CTL_DOC BANDO WITH (NOLOCK) ON BANDO.Id = D.LinkedDoc
            LEFT JOIN Document_Bando DB WITH (NOLOCK) ON DB.idHeader = D.LinkedDoc -- passiamo a left join invece di inner per gestire anchegli ODF ed i cig derivati
    
    --WHERE D.Id IN (477349)
    --ORDER BY idHeader DESC

GO
