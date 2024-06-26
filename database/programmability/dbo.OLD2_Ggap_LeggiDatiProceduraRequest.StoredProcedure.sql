USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_Ggap_LeggiDatiProceduraRequest]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---- @tipoDiRicerca indica se si tratta di Gara o SmartCig ==> Tipo di ricerca: 1 - SIMOG (Standard), 2 - SmartCIG/NoCIG
---- @operation indica se si tratta di Gara/Lotto ( = consultaNumeroGaraGgap, = consultaCigGgap ) o SmartCig ( = consultaSmartCigGgap )
CREATE PROCEDURE [dbo].[OLD2_Ggap_LeggiDatiProceduraRequest] ( @idRowServiceSimogRequests INT, @operation NVARCHAR(50), @tipoDiRicerca INT )
AS
BEGIN
    -- Sono necessari: 
    --                  connectedUserAlias  --> ProfiliUtente.pfulogin + _ + Aziende.azilog
    --                  connectedUserIdUo   --> Document_SIMOG_GARA.indexCollaborazione
    --                  tipoRicerca         --> Dipende se si arriva da una richiesta per la Gara o Lotto/i, comunque arriva in ingresso
    --
    -- Campi non previsti per tipoRicerca = 2 (cioè SmartCIG/NoCIG): 
    --                  idAppalto       -->
    --                  oggettoAppalto  -->
    --                  idGara          --> CTL_DOC.NumeroDocumento (per TipoDoc='RICHIESTA_CIG')
    --                  oggettoGara     --> CTL_DOC.Body
    -- 
    -- Necessari per tipoRicerca = 2 (cioè SmartCIG/NoCIG): 
    --                  cigSmartCigNoCig            --> Document_SIMOG_LOTTI.CIG    oppure  Document_SIMOG_SMART_CIG.smart_cig
    --                                                      No Document_SIMOG_GARA.id_gara (cioe numeroGara): Non può essere il
    --                                                      numeroGara (CIG della gara) ma solo un CIG del lotto: arrivato a questa
    --                                                      conclusione dopo aver testato la chiamata a GGAP. Non testato per SmartCig.
    --                                                      
    -- 
    -- Altri campi: 
    --                  idLottoSmartCigNoCig        --> ??? Document_SIMOG_LOTTI.idLottoEsterno  vs  CTL_DOC.NumeroDocumento (per TipoDoc='RICHIESTA_SMART_CIG')
    --                  oggettoLottoSmartCigNoCig   --> ??? Document_SIMOG_LOTTI.OGGETTO  vs  CTL_DOC.Body (per TipoDoc='RICHIESTA_SMART_CIG')
    --                  rfxId                       --> ??? ...
    --                  rfxReferenceId              --> ??? ...
    --                  tenderCode                  --> ??? ...
    --                  tenderReferenceCode         --> ??? ...

    
	SET NOCOUNT ON

    --DECLARE @idRowServiceSimogRequests INT = 253490
    --DECLARE @operation NVARCHAR(50) = 'consultaNumeroGaraGgap'
    --DECLARE @tipoDiRicerca INT = 1

    --DECLARE @idRowServiceSimogRequests INT = 253617
    --DECLARE @operation NVARCHAR(50) = 'consultaSmartCigGgap'
    --DECLARE @tipoDiRicerca INT = 2

    DECLARE @idBando INT
    DECLARE @idRichiestaCig INT
    DECLARE @cigSmartCigNoCig VARCHAR(50)
    DECLARE @connectedUserIdUo INT
    DECLARE @pfulogin VARCHAR(MAX)
    DECLARE @azilog VARCHAR(MAX)
    DECLARE @userAlias VARCHAR(MAX)
	--DECLARE @codiceProceduraSceltaContraente AS INT
	--DECLARE @ggapUnitaOrganizzative AS INT

    IF (@tipoDiRicerca = 1)
    BEGIN
        DECLARE @idLottoGgap INT
        DECLARE @oggettoLotto VARCHAR(MAX)
        

        IF (@operation = 'consultaNumeroGaraGgap')
        BEGIN
            -- Prendo l'id della RICHIESTA_CIG e del BANDO_GARA
            SELECT  @idRichiestaCig = D.Id -- RICHIESTA_CIG
                    , @idBando = BANDO.Id -- BANDO_GARA
                    --, D.LinkedDoc -- BANDO_GARA
                    --, @idRowDocSimogGara = G.idrow
                    --, @idRowServiceSimogRequests = R.idRow
                    --, @idHeaderDocSimogGara = G.idHeader
                    --, @cigSmartCigNoCig = G.id_gara -- No
                FROM Document_SIMOG_GARA G WITH (NOLOCK)
                        LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                            ON G.idrow = R.idRichiesta
                                AND R.operazioneRichiesta IN ('consultaNumeroGaraGgap', 'consultaCigGgap')
                                AND R.isOld = 0
                        INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.Id = G.idHeader
                        INNER JOIN CTL_DOC BANDO WITH (NOLOCK) ON BANDO.Id = D.LinkedDoc
                        LEFT JOIN Document_Bando DB WITH (NOLOCK) ON DB.idHeader = D.LinkedDoc
                WHERE R.idRow = @idRowServiceSimogRequests

            -- Se @idRichiestaCig e/o @idBando sono null allora l'idRichiesta del record nella Service_SIMOG_Requests non coincide con 
            --  un l'idRow di un record nella Document_SIMOG_GARA ma è l'id del doc RICHIESTA_CIG nella CTL_DOC
            IF (ISNULL(@idRichiestaCig,-1) = -1 AND ISNULL(@idBando,-1) = -1 )
            BEGIN
                SELECT  @idRichiestaCig = RicCig.Id -- RICHIESTA_CIG
                        , @idBando = Bando.Id -- BANDO_GARA
                    FROM Service_SIMOG_Requests R WITH (NOLOCK)
                            INNER JOIN CTL_DOC RicCig WITH (NOLOCK) ON R.idRichiesta = RicCig.Id
                            INNER JOIN CTL_DOC Bando WITH (NOLOCK) ON  RicCig.LinkedDoc = Bando.Id
                    WHERE R.idRow = @idRowServiceSimogRequests
                            --AND R.operazioneRichiesta IN ('consultaNumeroGaraGgap', 'consultaCigGgap')
                            --AND R.isOld = 0
            END
        END
        ELSE -- IF (@operation = 'consultaCigGgap')
        BEGIN
            -- Prendo l'id del BANDO_GARA, l'id lotto di GGAP e l'oggetto del lotto
            SELECT  @idBando = D.LinkedDoc -- BANDO_GARA
                    --, @idRichiestaCig = D.Id -- RICHIESTA_CIG
                    --, @idBando = BANDO.idHeader -- BANDO_GARA
                    , @idLottoGgap = L.idLottoEsterno
                    , @oggettoLotto = L.OGGETTO
                    , @cigSmartCigNoCig = L.CIG
                FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                        LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                            ON L.idrow = R.idRichiesta
                                AND R.operazioneRichiesta IN ('garaInserisciGgap', 'lottoInserisciGgap')
                                AND R.isOld = 0
                        INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.id
                        LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
                WHERE R.idRow = @idRowServiceSimogRequests


            -- Prendo l'id della RICHIESTA_CIG
            SELECT @idRichiestaCig = Id
                FROM CTL_DOC WITH (NOLOCK)
                WHERE LinkedDoc=@idBando AND TipoDoc = 'RICHIESTA_CIG'

        END

    
        -- Costruisco lo userAlias/connectedUserAlias
        SELECT @pfulogin=PU.pfulogin
               , @azilog=A.azilog
            FROM ProfiliUtente PU WITH (NOLOCK)
                    INNER JOIN Aziende A WITH (NOLOCK) ON pfuidazi = idazi
            WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idBando)

        SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)) -- E_SABATO_FERRARO_5_ER000AA
            -- SET @userAlias = 'wsApp' -- SET @userAlias = 'E_CORRADO_VERSOLATO_FV000AA' -- TODO: rimuovere, è solo per test
        

        -- Prendo l'id dell'unità organizzativa ossia connectedUserIdUo (e l'id della sceltà contraente)
        SELECT @connectedUserIdUo = indexCollaborazione  -- l'id dell'unità organizzativa
               --, @codiceProceduraSceltaContraente = ID_SCELTA_CONTRAENTE
            FROM Document_SIMOG_GARA WITH (NOLOCK)
            WHERE idHeader=@idRichiestaCig


        -- Prendo l'id della gara che GGAP fornisce
        DECLARE @idGaraGgap INT

            SELECT @idGaraGgap = CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT)
                FROM CTL_DOC
                WHERE Id = @idRichiestaCig AND TipoDoc='RICHIESTA_CIG'
            

        -- Prendo l'oggetto della gara
        DECLARE @oggetto NVARCHAR(MAX)

            SELECT @oggetto = Body
                FROM CTL_DOC WITH (NOLOCK)
                WHERE Id=@idBando



        -- Restituisco i dati
        SELECT @userAlias           AS userAlias -- connectedUserAlias
               , @connectedUserIdUo AS connectedUserIdUo
               , @tipoDiRicerca     AS tipoDiRicerca

               , @idGaraGgap        AS idGaraGgap
               , @oggetto           AS oggettoGara
               --, @codiceProceduraSceltaContraente   AS codiceProceduraSceltaContraente
               , CASE
                    WHEN ISNULL(@cigSmartCigNoCig,'') = '' THEN NULL
                    ELSE @cigSmartCigNoCig
                 END AS cigSmartCigNoCig
               , @idLottoGgap       AS idLottoSmartCigNoCig
               , @oggettoLotto      AS oggettoLottoSmartCigNoCig
        
    END
    ELSE -- IF (@tipoDiRicerca = 2)
    BEGIN
        -- Prendo l'id della RichiestaSmartCig andando sulla tabella Service_SIMOG_Requests e avendo l'idRow
        DECLARE @idSmartCig INT

            SELECT @idSmartCig = idRichiesta
                FROM Service_SIMOG_Requests
                WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation -- 'smartCigInserisciGgap', 'consultaSmartCigGgap'


        -- Prendo l'id dello SmartCig di GGAP, l'oggetto della gara
        DECLARE @idSmartCigGgap INT
        DECLARE @oggettoSmartCig VARCHAR(MAX)

            SELECT @idSmartCigGgap = CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT)
                   --@idSmartCigGgap = (CASE
                   --                       WHEN NumeroDocumento IS NOT NULL OR NumeroDocumento <> '' THEN CAST(NumeroDocumento AS INT) --CONVERT(INT, NumeroDocumento)
                   --                       ELSE NULL
                   --                  END)
                   , @oggettoSmartCig = Body
                FROM CTL_DOC WITH (NOLOCK)
                WHERE Id=@idSmartCig AND TipoDoc = 'RICHIESTA_SMART_CIG'


        -- Prendo l'id dell'unità organizzativa ossia connectedUserIdUo (e l'id della sceltà contraente)
        SELECT @connectedUserIdUo = indexCollaborazione
               --, @codiceProceduraSceltaContraente = ID_SCELTA_CONTRAENTE
               , @cigSmartCigNoCig = smart_cig
            FROM Document_SIMOG_SMART_CIG WITH (NOLOCK)
            WHERE idHeader=@idSmartCig

            
        -- Costruisco lo userAlias/connectedUserAlias
        SELECT @pfulogin=pfulogin
               , @azilog=azilog
            FROM ProfiliUtente WITH (NOLOCK)
                    INNER JOIN Aziende WITH (NOLOCK) ON pfuidazi = idazi
            WHERE IdPfu = (SELECT idpfu FROM ctl_doc WHERE Id = @idSmartCig)

        SET @userAlias = CAST(@pfulogin AS NVARCHAR(MAX)) + '_' + CAST(@azilog AS NVARCHAR(MAX)) -- E_SABATO_FERRARO_5_ER000AA
            -- SET @userAlias = 'wsApp' -- SET @userAlias = 'E_CORRADO_VERSOLATO_FV000AA' -- TODO: rimuovere, è solo per test
        


        -- Restituisco i dati
        SELECT @userAlias           AS userAlias -- connectedUserAlias
               , @connectedUserIdUo AS connectedUserIdUo
               , @tipoDiRicerca     AS tipoDiRicerca
               , CASE
                    WHEN ISNULL(@cigSmartCigNoCig,'') = '' THEN NULL
                    ELSE @cigSmartCigNoCig
                 END                AS cigSmartCigNoCig
               , @idSmartCigGgap    AS idLottoSmartCigNoCig
               , @oggettoSmartCig   AS oggettoLottoSmartCigNoCig
               , @idSmartCig        AS idRichiestaSmartCig
               --, @codiceProceduraSceltaContraente   AS codiceProceduraSceltaContraente
        
    END

END

GO
