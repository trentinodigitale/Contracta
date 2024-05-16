USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_LogCig]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- Può contenere il valore per il record della Gara (garaInserisciGgap) o del Lotto (lottoInserisciGgap)
CREATE PROCEDURE [dbo].[Ggap_LogCig] ( @idRowServiceSimogRequests int , @idGgap NVARCHAR(50) ,
                                    @operation NVARCHAR(50) , @statoRichiesta NVARCHAR(50) ,
                                    @requestString NVARCHAR(MAX) , @responseString NVARCHAR(MAX) ,
                                    @msgError NVARCHAR(1000) )
AS
BEGIN
    
	SET NOCOUNT ON
    

    IF (ISNULL(@idGgap, '') = '')
    BEGIN

        IF (ISNULL(@operation, '') <> 'lottoInserisciGgap')
        BEGIN
            UPDATE Service_SIMOG_Requests
                SET statoRichiesta = CASE
                		                WHEN @msgError LIKE '%Server Error%' AND numRetry < 5 AND operazioneRichiesta = 'consultaNumeroGaraGgap' THEN 'Inserita'
                		                ELSE @statoRichiesta
                		             END
                	, msgError = CASE
                		            WHEN CHARINDEX(' --- ' + @msgError, ISNULL(msgError, '')) = 0 THEN ISNULL(msgError, '') + ' --- ' + @msgError -- CHARINDEX(search substring, into string, start at position)
                		            ELSE ISNULL(msgError, '') + ' --- ' + @msgError
                		         END
                    , numRetry = ISNULL(numRetry,0) + 1
                	, outputWS = ISNULL(outputWS, '') + ' ---- ' + @responseString
                	, inputWS = ISNULL(inputWS, '') + ' ---- ' + @requestString
                WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation
        END
        ELSE -- IF (ISNULL(@operation, '') = 'lottoInserisciGgap')
        BEGIN
            UPDATE Service_SIMOG_Requests
                SET statoRichiesta = CASE
                		                WHEN @msgError LIKE '%Server Error%' AND numRetry < 5 AND operazioneRichiesta = 'consultaNumeroGaraGgap' THEN 'Inserita'
                		                ELSE @statoRichiesta
                		             END
                	, msgError = CASE
                		            WHEN CHARINDEX(' --- ' + @msgError, ISNULL(msgError, '')) = 0 THEN ISNULL(msgError, '') + ' --- ' + @msgError -- CHARINDEX(search substring, into string, start at position)
                		            ELSE ISNULL(msgError, '') + ' ' + @msgError
                		         END
                    , numRetry = ISNULL(numRetry,0) + 1
                	, outputWS = ISNULL(outputWS, '') + ' ---- ' + @responseString
                	, inputWS = ISNULL(inputWS, '') + ' ---- ' + @requestString
                WHERE idRichiesta IN (SELECT  L.idRow
	        			                    FROM Document_SIMOG_GARA G WITH (NOLOCK)
	        			                    		INNER JOIN Service_SIMOG_Requests R WITH(NOLOCK) ON G.idrow = R.idRichiesta 
	        			                    		INNER JOIN Document_SIMOG_LOTTI L WITH(NOLOCK) ON G.idHeader = L.idHeader
	        			                    		INNER JOIN CTL_DOC D WITH (NOLOCK) ON G.idHeader = D.Id
	        			                    WHERE R.idRow = @idRowServiceSimogRequests AND R.operazioneRichiesta = 'garaInserisciGgap' AND D.TipoDoc = 'RICHIESTA_CIG'
                       )
                       AND operazioneRichiesta = @operation
        END

    END
    ELSE
    BEGIN

        IF (ISNULL(@operation, '') <> 'lottoInserisciGgap')
        BEGIN
            UPDATE Service_SIMOG_Requests
                SET statoRichiesta = @statoRichiesta
                    , numRetry = ISNULL(numRetry,0) + 1
                	, datoRichiesto = @idGgap
                	, msgError = CASE
                                    WHEN (ISNULL(@msgError, '') + ' --- OK') = ' --- OK' THEN ' --- OK'
                                    WHEN msgError LIKE '% --- OK%' THEN @msgError
                                    --ELSE msgError + ' --- OK'
                                    ELSE msgError + ' ' + @msgError
                                 END
                	, outputWS = ISNULL(outputWS, '') + ' ---- ' + @responseString
                	, inputWS = ISNULL(inputWS, '') + ' ---- ' + @requestString
                WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation
        END
        ELSE -- IF (ISNULL(@operation, '') = 'lottoInserisciGgap')
        BEGIN
            IF (ISNULL(@msgError, '') = '')
            BEGIN
                UPDATE Service_SIMOG_Requests
                    SET statoRichiesta = @statoRichiesta
                        , numRetry = ISNULL(numRetry,0) + 1
                    	, datoRichiesto = @idGgap
                    	, msgError = CASE
                                        WHEN (ISNULL(@msgError, '') + ' --- OK') = ' --- OK' THEN ' --- OK'
                                        WHEN msgError LIKE '% --- OK%' THEN @msgError
                                        --ELSE msgError + ' --- OK'
                                        ELSE msgError + ' ' + @msgError
                                     END
                    	, outputWS = ISNULL(outputWS, '') + ' ---- ' + @responseString
                    	, inputWS = ISNULL(inputWS, '') + ' ---- ' + @requestString
                    WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation
            END
            ELSE -- Se c'è stato un errore, ossia @msgError è valorizzato
            BEGIN
                UPDATE Service_SIMOG_Requests
                    SET statoRichiesta = @statoRichiesta
                        , numRetry = ISNULL(numRetry,0) + 1
                    	, datoRichiesto = @idGgap
                    	, msgError = CASE
                                        WHEN (ISNULL(@msgError, '') + ' --- OK') = ' --- OK' THEN ' --- OK'
                                        WHEN msgError LIKE '% --- OK%' THEN @msgError
                                        --ELSE msgError + ' --- OK'
                                        ELSE msgError + ' ' + @msgError
                                     END
                    	, outputWS = ISNULL(outputWS, '') + ' ---- ' + @responseString
                    	, inputWS = ISNULL(inputWS, '') + ' ---- ' + @requestString
                    WHERE idRichiesta IN (SELECT  L.idRow
	            			                FROM Document_SIMOG_GARA G WITH (NOLOCK)
	            			                		INNER JOIN Service_SIMOG_Requests R WITH(NOLOCK) ON G.idrow = R.idRichiesta 
	            			                		INNER JOIN Document_SIMOG_LOTTI L WITH(NOLOCK) ON G.idHeader = L.idHeader
	            			                		INNER JOIN CTL_DOC D WITH (NOLOCK) ON G.idHeader = D.Id
	            			                WHERE R.idRow = @idRowServiceSimogRequests AND R.operazioneRichiesta = 'garaInserisciGgap' AND D.TipoDoc = 'RICHIESTA_CIG'
                          )
                          AND operazioneRichiesta = @operation
            END
        END

    END

END
GO
