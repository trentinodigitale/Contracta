USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_SetErrorForModificaLotto]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
CREATE PROCEDURE [dbo].[Ggap_SetErrorForModificaLotto] ( @idRowServiceSimogRequests INT
                                                      , @statoRichiesta NVARCHAR(50)
                                                      , @messaggioErrore NVARCHAR(MAX))
AS
BEGIN
    
	SET NOCOUNT ON

    --DECLARE @idRowServiceSimogRequests INT = 253496            

    -- Aggiorno il record della tabella Service_SIMOG_Requests per il lotto impostando.
    UPDATE Service_SIMOG_Requests
        SET statoRichiesta = @statoRichiesta -- statoRichiesta = 'RicevutoErrore'
            , msgError = CASE
                            WHEN @messaggioErrore LIKE '%lotto%' THEN @messaggioErrore
                            --ELSE '<img src="../images/Domain/State_ERR.gif"><br> Errore nella gara.'
                            ELSE 'Errore nella gara.'
                         END
            , isOld = 1
        WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta IN ('lottoModificaGgap')


    -- Imposto lo StatoRichiestaLOTTO nel record della Document_SIMOG_LOTTI
    UPDATE Document_SIMOG_LOTTI
        SET StatoRichiestaLOTTO = @statoRichiesta
            --, AzioneProposta = '...'
        FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                    ON L.idrow = R.idRichiesta
                        AND R.operazioneRichiesta IN ('lottoModificaGgap')
                        AND R.isOld = 1
        WHERE R.idRow = @idRowServiceSimogRequests AND L.AzioneProposta = 'Update'
END

GO
