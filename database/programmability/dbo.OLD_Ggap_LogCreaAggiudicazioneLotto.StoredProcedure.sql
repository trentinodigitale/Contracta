USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Ggap_LogCreaAggiudicazioneLotto]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- @operation dovrebbe contenere il valore per il record della Gara in modifica (garaModificaGgap)
CREATE PROCEDURE [dbo].[OLD_Ggap_LogCreaAggiudicazioneLotto] ( @idRowServiceSimogRequests INT = -1, @idLotto INT = -1, @idPfu INT = -1
                                                        , @idAggiudicazioneGgap INT, @operation NVARCHAR(50)
                                                        , @statoRichiesta NVARCHAR(50), @requestString NVARCHAR(MAX)
                                                        , @responseString NVARCHAR(MAX), @msgError NVARCHAR(1000) )
AS
BEGIN
    
	SET NOCOUNT ON

    IF (@idRowServiceSimogRequests = -1)
    BEGIN
        SET @msgError = CASE
                            WHEN (ISNULL(@msgError, '') + ' --- OK') = ' --- OK' THEN ' --- OK'
                            ELSE ' --- ' + @msgError
                        END

	    -- Si inserisce la richiesta
        INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, msgError, outputWS, inputWS, idPfuRup, dateIn)
         -- VALUES ( @idLotto, 'creaAggiudicazioneLottoGgapMicrolotto', 'RicevutaRisposta', @msgError, @responseString, @requestString, @idPfu, GETDATE() )
            VALUES ( @idLotto, 'creaAggiudicazioneLottoGgapMicrolotto', @statoRichiesta, @msgError, ' ---- ' + @responseString, ' ---- ' + @requestString, @idPfu, GETDATE() )
    END
    ELSE -- IF (@idLotto = -1 OR @idLotto = (SELECT idPfuRup FROM Service_SIMOG_Requests WHERE idRow = @idRowServiceSimogRequests))
    BEGIN
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta
                , numRetry = ISNULL(numRetry,0) + 1
            	, datoRichiesto = CAST(@idAggiudicazioneGgap AS VARCHAR(50))
            	, msgError = CASE
                                WHEN (ISNULL(@msgError, '') + ' --- OK') = ' --- OK' THEN ' --- OK'
                                --WHEN msgError LIKE '% --- OK%' THEN @msgError
                                --ELSE msgError + ' ' + @msgError
                                ELSE ' --- ' + @msgError
                             END
            	--, outputWS = ISNULL(outputWS, '') + ' ---- ' + @responseString
            	--, inputWS = ISNULL(inputWS, '') + ' ---- ' + @requestString
            	, outputWS = ' ---- ' + @responseString
            	, inputWS = ' ---- ' + @requestString
            WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation
    END
END
GO
