USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_DeleteRecordsForGaraAndLotti]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- Se @operazione è 'consultaNumeroGaraGgap' allora @idRowServiceSimogRequests contiene il valore per il record della Gara (operazioneRichiesta='consultaNumeroGaraGgap')
--  altrimenti se è 'consultaCigGgap' contiene il valore per il record del Lotto (operazioneRichiesta='consultaCigGgap')
CREATE PROCEDURE [dbo].[Ggap_DeleteRecordsForGaraAndLotti] ( @idRowServiceSimogRequests INT, @operazione NVARCHAR(50)
                                                            , @statoRichiesta NVARCHAR(50), @messaggioErrore NVARCHAR(MAX))
AS
BEGIN
    
	SET NOCOUNT ON

    DECLARE @idRichiestaCig INT
    DECLARE @idBando INT
    
    IF (@operazione = 'consultaNumeroGaraGgap')
    BEGIN
        --DECLARE @idRowServiceSimogRequests INT = 253496
        
        -- Imposto lo StatoRichiestaGARA nel record della gara nella tabella Document_SIMOG_GARA
        UPDATE Document_SIMOG_GARA
            SET StatoRichiestaGARA = @statoRichiesta
                , EsitoControlli = '<img src="../images/Domain/State_ERR.gif"><br>' + @messaggioErrore
            FROM Document_SIMOG_GARA G
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta
            WHERE R.idRow = @idRowServiceSimogRequests


        -- Imposto in errore il record nella Service_SIMOG_Requests
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta
                , msgError = @messaggioErrore
            WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operazione
        

        -- Prendo l'id della RICHIESTA_CIG per poter poi impostare in errore lo statoRichiesta dei lotti correlati alla gara.
        SELECT  @idRichiestaCig = D.Id -- RICHIESTA_CIG
                , @idBando = D.LinkedDoc -- BANDO_GARA
            FROM Document_SIMOG_GARA G WITH (NOLOCK)
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON G.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN (@operazione)
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON D.id = G.idHeader
            WHERE R.idRow = @idRowServiceSimogRequests


        -- Imposto lo StatoRichiestaLOTTO in tutti i record della Document_SIMOG_LOTTI dato l'idHeader
        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON L.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('consultaCigGgap')
            WHERE L.idHeader = @idRichiestaCig


        -- Imposto in errore il record nella Service_SIMOG_Requests
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta
                , msgError = @messaggioErrore
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON L.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('consultaCigGgap')
            WHERE L.idHeader = @idRichiestaCig
    END
    ELSE IF (@operazione = 'consultaCigGgap')
    BEGIN
        --DECLARE @idRowServiceSimogRequests INT = 212323

        -- Prendo l'id della RICHIESTA_CIG per poter poi impostare in errore lo statoRichiesta dei lotti correlati alla gara.
        SELECT  @idRichiestaCig = D.Id -- RICHIESTA_CIG
                --, @idRichiestaCig = L.idHeader -- RICHIESTA_CIG
                , @idBando = D.LinkedDoc -- BANDO_GARA
                --, @idBando = BANDO.idHeader -- BANDO_GARA
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                                ON L.idrow = R.idRichiesta
                                    AND R.operazioneRichiesta IN (@operazione) -- 'consultaCigGgap'
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.Id
                    --LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
            WHERE R.idRow = @idRowServiceSimogRequests
            

        -- Imposto lo StatoRichiestaLOTTO in tutti i record della Document_SIMOG_LOTTI dato l'idHeader
        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON L.idRow = R.idRichiesta 
            WHERE R.idRow = @idRowServiceSimogRequests
                    AND R.operazioneRichiesta IN (@operazione)
                    AND L.idHeader = @idRichiestaCig

        UPDATE Document_SIMOG_GARA
            SET StatoRichiestaGARA = @statoRichiesta
            FROM Document_SIMOG_GARA G WITH (NOLOCK)
                    INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta 
            WHERE R.idRow = @idRowServiceSimogRequests
                    AND R.operazioneRichiesta = 'consultaNumeroGaraGgap'
                    AND G.idHeader = @idRichiestaCig
    END


    -- Annullo il documento RICHIESTA_CIG, se esiste
	UPDATE CTL_DOC
	    SET StatoFunzionale='Annullato'
	    WHERE Id = @idRichiestaCig AND TipoDoc IN ('RICHIESTA_CIG')


    -- Se @idRichiestaCig e/o @idBando sono null allora l'idRichiesta del record nella Service_SIMOG_Requests non coincide con 
    --  un l'idRow di un record nella Document_SIMOG_GARA ma è l'id del doc RICHIESTA_CIG nella CTL_DOC
    IF ( /* ISNULL(@idRichiestaCig,-1) = -1 AND */ ISNULL(@idBando,-1) = -1 )
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

    -- Cancello il flag di controllo cosicché nel processo BANDO_GARA-LOAD_PRODOTTI_SUB (passo 65, DescrStep 'SIMOG. Se richiesto invoco il recupero dei dati') si 
    -- possa invocare la richiesta dati simog (cioè eseguire la SP RICHIESTA_CIG_CREATE_FROM_VERIFICA_INFORMAZIONI)
    DELETE FROM CTL_DOC_Value where IdHeader = @idBando and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'

END

GO
