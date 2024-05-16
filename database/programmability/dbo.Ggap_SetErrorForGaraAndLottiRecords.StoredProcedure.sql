USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_SetErrorForGaraAndLottiRecords]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- Se @isFromCreaGara è true allora @idBando è valorizzato e @idRowServiceSimogRequests contiene il valore per il record della Gara (garaInserisciGgap) 
--  altrimenti contiene il valore per il record del Lotto (lottoInserisciGgap)
CREATE PROCEDURE [dbo].[Ggap_SetErrorForGaraAndLottiRecords] ( @idRowServiceSimogRequests INT
                                                            , @statoRichiesta NVARCHAR(50)
                                                            , @messaggioErrore NVARCHAR(MAX)
                                                            , @isFromCreaGara BIT
                                                            , @idBando INT)
AS
BEGIN
    
	SET NOCOUNT ON

    DECLARE @idRichiestaCig INT
    
    -- Se @isFromCreaGara è false allora recupero l'id del BANDO_GARA utilizzando @idRowServiceSimogRequests che contine il valore relativo al record del Lotto.
    IF (@isFromCreaGara = 0)
    BEGIN
        --DECLARE @idRowServiceSimogRequests INT = 212323


        -- Prendo l'id della RICHIESTA_CIG per poter poi impostare in errore lo statoRichiesta dei lotti correlati alla gara.
        SELECT  @idBando = D.LinkedDoc -- BANDO_GARA
                --, @idRichiestaCig = L.idHeader -- RICHIESTA_CIG
                , @idRichiestaCig = D.Id -- RICHIESTA_CIG
                --, @idBando = BANDO.idHeader -- BANDO_GARA
                --*
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON L.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('lottoInserisciGgap') -- 'garaInserisciGgap', 
                            AND R.isOld = 0
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.Id
                    LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
            WHERE R.idRow = @idRowServiceSimogRequests
            

        -- Aggiorno il record della tabella Service_SIMOG_Requests per i lotti impostando lo statoRichiesta in errore e scrivendo un messaggio riguardo all'errore.
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta -- statoRichiesta = 'RicevutoErrore'
                , msgError = msgError + ' ' + @messaggioErrore
                , isOld = 1
                FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                        INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON L.idRow = R.idRichiesta 
                WHERE R.idRow = @idRowServiceSimogRequests
                        AND R.statoRichiesta NOT IN ('ErroreLogin','RicevutoErrore','Errore')
                        AND R.isOld = 0
                        AND R.operazioneRichiesta IN ('lottoInserisciGgap') --AND R.operazioneRichiesta LIKE '%Ggap%'


        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
                --, AzioneProposta = '...'
                FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                        INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON L.idRow = R.idRichiesta 
                WHERE R.idRow = @idRowServiceSimogRequests
                        AND R.isOld = 0
                        AND R.operazioneRichiesta IN ('lottoInserisciGgap')
                        AND L.idHeader = @idRichiestaCig
    END
    ELSE
    BEGIN
        -- Aggiorno i record della tabella Service_SIMOG_Requests sia per la gara che per i lotti impostando
        --  lo statoRichiesta in errore, isOld = 1 e scrivendo un messaggio riguardo all'errore.
        -- Imposto in Document_SIMOG_GARA lo StatoRichiestaGARA in 'RicevutoErrore' o 'Errore' per il record della gara.
        -- Imposto in StatoRichiestaLOTTO lo StatoRichiestaLOTTO in 'RicevutoErrore' o 'Errore' per tutti i lotti associati alla gara.


        --DECLARE @idRowServiceSimogRequests INT = 253496

        -- Imposto lo statoRichiesta della gara in errore nella tabella Service_SIMOG_Requests.
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta -- statoRichiesta = 'RicevutoErrore'
                , msgError = @messaggioErrore
                , isOld = 1
                FROM Document_SIMOG_GARA G
                        INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta 
                WHERE R.idrow = @idRowServiceSimogRequests
                        AND R.statoRichiesta NOT IN ('ErroreLogin','RicevutoErrore','Errore')
                        AND R.isOld = 0
                        AND R.operazioneRichiesta IN ('garaInserisciGgap') --AND R.operazioneRichiesta LIKE '%Ggap%'


        -- Imposto lo StatoRichiestaGARA nel record della gara nella tabella Document_SIMOG_GARA
        UPDATE Document_SIMOG_GARA
            SET StatoRichiestaGARA = @statoRichiesta
                , EsitoControlli = '<img src="../images/Domain/State_ERR.gif"><br>' + @messaggioErrore
                --, AzioneProposta = '...'
                FROM Document_SIMOG_GARA G
                        INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta
                WHERE R.idRow = @idRowServiceSimogRequests
        

        -- Prendo l'id della RICHIESTA_CIG per poter poi impostare in errore lo statoRichiesta dei lotti correlati alla gara.
        SELECT  @idRichiestaCig = D.Id -- RICHIESTA_CIG
            FROM Document_SIMOG_GARA G WITH (NOLOCK)
                    LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON G.idrow = R.idRichiesta
                            AND R.statoRichiesta = @statoRichiesta
                            AND R.operazioneRichiesta IN ('garaInserisciGgap') -- , 'lottoInserisciGgap'
                            AND R.isOld = 1
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = G.idHeader
                    --INNER JOIN CTL_DOC BANDO WITH (NOLOCK) ON BANDO.Id = D.LinkedDoc
                    --LEFT JOIN Document_Bando DB WITH (NOLOCK) ON DB.idHeader = D.LinkedDoc
            WHERE R.idRow = @idRowServiceSimogRequests
            

        -- Imposto lo statoRichiesta dei lotti in errore nella tabella Service_SIMOG_Requests.
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta -- statoRichiesta = 'RicevutoErrore'
                , msgError = CASE
                                WHEN @messaggioErrore LIKE '%lotto%' THEN @messaggioErrore
                                --ELSE '<img src="../images/Domain/State_ERR.gif"><br> Errore nella gara.'
                                ELSE 'Errore nella gara.'
                             END
                , isOld = 1
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON L.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('lottoInserisciGgap') -- 'garaInserisciGgap', 
                            AND R.isOld = 0
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.id
                    LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
            WHERE L.idHeader = @idRichiestaCig


        -- Imposto lo StatoRichiestaLOTTO in tutti i record della Document_SIMOG_LOTTI dato l'idHeader
        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
                --, AzioneProposta = '...'
                FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                        LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                            ON L.idrow = R.idRichiesta
                                AND R.operazioneRichiesta IN ('lottoInserisciGgap') -- 'garaInserisciGgap', 
                                AND R.isOld = 0
                        --INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.id
                        --LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
                WHERE L.idHeader = @idRichiestaCig
    END


    
    -- Annullo il documento RICHIESTA_CIG, se esiste
	UPDATE CTL_DOC
	    --SET NumeroDocumento = NULL
	    SET StatoFunzionale='Annullato' --, Deleted =  1
	    WHERE LinkedDoc = @idBando AND TipoDoc IN ('RICHIESTA_CIG')



--  UPDATE CTL_DOC SET StatoFunzionale='InLavorazione', Deleted = 0 WHERE LinkedDoc = 476196 AND TipoDoc='RICHIESTA_CIG'
--  select Deleted, StatoFunzionale, NumeroDocumento, * from CTL_DOC WITH(NOLOCK) where TipoDoc IN ('RICHIESTA_SMART_CIG','RICHIESTA_CIG') and LinkedDoc=476196
--  UPDATE CTL_DOC SET StatoFunzionale='InLavorazione', Deleted =  0 WHERE LinkedDoc = 476023 AND TipoDoc='RICHIESTA_SMART_CIG'

END

GO
