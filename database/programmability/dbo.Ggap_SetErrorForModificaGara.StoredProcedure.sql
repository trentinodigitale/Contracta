USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_SetErrorForModificaGara]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- Se @isFromGara è true allora @idBando è valorizzato e @idRowServiceSimogRequests contiene il valore per il record della Gara (garaModificaGgap)
CREATE PROCEDURE [dbo].[Ggap_SetErrorForModificaGara] ( @idRowServiceSimogRequests INT
                                                     , @statoRichiesta NVARCHAR(50)
                                                     , @messaggioErrore NVARCHAR(MAX)
                                                     --, @isFromGara BIT
                                                     , @idBando INT)
AS
BEGIN
    
	SET NOCOUNT ON

    -- Aggiorno i record della tabella Service_SIMOG_Requests sia per la gara che per i lotti impostando
    --  lo statoRichiesta in errore, isOld = 1 e scrivendo un messaggio riguardo all'errore.
    -- Imposto in Document_SIMOG_GARA lo StatoRichiestaGARA in 'RicevutoErrore' o 'Errore' per il record della gara.
    -- Imposto in StatoRichiestaLOTTO lo StatoRichiestaLOTTO in 'RicevutoErrore' o 'Errore' per tutti i lotti associati alla gara.


    --DECLARE @idRowServiceSimogRequests INT = 253496
    DECLARE @idRichiestaCig INT
    

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
                    AND R.operazioneRichiesta IN ('garaModificaGgap')


    -- Imposto lo StatoRichiestaGARA nel record della gara nella tabella Document_SIMOG_GARA
    UPDATE Document_SIMOG_GARA
        SET StatoRichiestaGARA = @statoRichiesta
            , EsitoControlli = '<img src="../images/Domain/State_ERR.gif"><br>' + @messaggioErrore
            --, AzioneProposta = 'Delete'
            FROM Document_SIMOG_GARA G
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta
            WHERE R.idRow = @idRowServiceSimogRequests
    

    -- Prendo l'id della RICHIESTA_CIG per poter poi impostare in errore lo statoRichiesta dei lotti correlati alla gara.
    SELECT  @idRichiestaCig = D.Id -- RICHIESTA_CIG
        FROM Document_SIMOG_GARA G WITH (NOLOCK)
                LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                    ON G.idrow = R.idRichiesta
                        AND R.statoRichiesta = @statoRichiesta
                        AND R.operazioneRichiesta IN ('garaModificaGgap')
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
                        AND R.operazioneRichiesta IN ('lottoModificaGgap')
                        AND R.isOld = 0
                INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.id
                LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
        WHERE L.idHeader = @idRichiestaCig


    -- Imposto lo StatoRichiestaLOTTO in tutti i record della Document_SIMOG_LOTTI dato l'idHeader
    UPDATE Document_SIMOG_LOTTI
        SET StatoRichiestaLOTTO = @statoRichiesta
            --, AzioneProposta = 'Delete'
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON L.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('lottoModificaGgap') -- 'garaInserisciGgap', 
                            AND R.isOld = 0
                    --INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.id
                    --LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
            WHERE L.idHeader = @idRichiestaCig

END

GO
