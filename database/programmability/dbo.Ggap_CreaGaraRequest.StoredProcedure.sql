USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_CreaGaraRequest]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests, per il record 
--  relativo alla Gara (garaInserisciGgap)
CREATE PROCEDURE [dbo].[Ggap_CreaGaraRequest] ( @idRowServiceSimogRequests int )
AS
BEGIN
    -- Sono obbligatori: 
    --                  connectedUserIdUo               --> Document_SIMOG_GARA.indexCollaborazione
    --                  connectedUserAlias              --> ProfiliUtente.pfulogin + _ + Aziende.azilog
    --                  codiceRiferimentoGara           --> CTL_DOC.Protocollo
    --                  oggettoGara                     --> CTL_DOC.Body

    
	SET NOCOUNT ON

    --DECLARE @idRowServiceSimogRequests INT = 212322

    -- Prendo l'id della RICHIESTA_CIG e del BANDO_GARA
    DECLARE @idBando INT -- = 476196
    DECLARE @idRichiestaCig INT -- = 476199
    DECLARE @idRowDocSimogGara INT -- = 1192
    --DECLARE @idRowServiceSimogRequests INT -- = 212322
    --DECLARE @idHeaderDocSimogGara INT -- = 476199

        SELECT  @idRichiestaCig = D.Id -- RICHIESTA_CIG
                --, D.LinkedDoc -- BANDO_GARA
                , @idBando = BANDO.Id -- BANDO_GARA
                , @idRowDocSimogGara = G.idrow
                --, @idRowServiceSimogRequests = R.idRow
                --, @idHeaderDocSimogGara = G.idHeader
                --*
            FROM Document_SIMOG_GARA G WITH (NOLOCK)
                    LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON G.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('garaInserisciGgap', 'lottoInserisciGgap')
                            AND R.isOld = 0
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = G.idHeader
                    INNER JOIN CTL_DOC BANDO WITH (NOLOCK) ON BANDO.Id = D.LinkedDoc
                    LEFT JOIN Document_Bando DB WITH (NOLOCK) ON DB.idHeader = D.LinkedDoc
            WHERE R.idRow = @idRowServiceSimogRequests

        --SELECT  @idRichiestaCig, @idBando, @idRowDocSimogGara --, @idHeaderDocSimogGara --, @idRowServiceSimogRequests


    -- Costruisco lo userAlias/connectedUserAlias
    DECLARE @pfulogin VARCHAR(MAX)
    DECLARE @azilog VARCHAR(MAX)

        SELECT @pfulogin=PU.pfulogin
               , @azilog=A.azilog
            FROM ProfiliUtente PU WITH (NOLOCK)
                    INNER JOIN Aziende A WITH (NOLOCK) ON pfuidazi = idazi
            WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idBando)

    DECLARE @userAlias VARCHAR(MAX) -- connectedUserAlias
        SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)) -- E_SABATO_FERRARO_5_ER000AA
        -- SET @userAlias = 'wsApp' -- 'E_CORRADO_VERSOLATO_FV000AA' -- TODO: rimuovere, è solo per test

    
    -- Prendo l'oggetto e il protocollo (ossia codiceRiferimentoGara per GGAP)
    DECLARE @oggetto NVARCHAR(MAX)
    DECLARE @Protocollo NVARCHAR(MAX) -- codiceRiferimentoGara

    SELECT @oggetto = Body
           , @Protocollo = Protocollo
        FROM CTL_DOC WITH (NOLOCK)
        WHERE Id=@idBando
    

    -- Prendo l'id della gara che GGAP fornisce
    DECLARE @idGaraGgap INT

        SELECT @idGaraGgap = CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT)
               --, @idGaraGgap = (CASE
               --                 WHEN ISNULL(NumeroDocumento, '') = '' THEN NumeroDocumento
               --                 ELSE CAST(NumeroDocumento AS INT) --CONVERT(INT, NumeroDocumento)
               --              END)
               --, @idRichiestaCig = Id
            FROM CTL_DOC WITH (NOLOCK)
            WHERE LinkedDoc=@idBando AND TipoDoc='RICHIESTA_CIG'
        
           

    -- Restituisco i dati
    SELECT indexCollaborazione              AS connectedUserIdUo -- l'id dell'unità organizzativa
           , @userAlias                     AS userAlias
           , @Protocollo                    AS protocollo
           , @oggetto                       AS oggetto
           , @idGaraGgap                    AS idGara

           , NUMERO_LOTTI                   AS numeroLotti
           --, CF_AMMINISTRAZIONE             AS codiceFiscaleAmministrazione

           , @idBando                       AS idBando
           , @idRichiestaCig                AS idRichiestaCig
           , @idRowDocSimogGara             AS idRowDocSimogGara
           --, @idRowServiceSimogRequests         AS idRowServiceSimogRequests
        FROM Document_SIMOG_GARA WITH (NOLOCK)
        WHERE idHeader=@idRichiestaCig AND AzioneProposta = 'Insert'

END

GO
