USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_LogGaraInModifica]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- @operation dovrebbe contenere il valore per il record della Gara in modifica (garaModificaGgap)
CREATE PROCEDURE [dbo].[Ggap_LogGaraInModifica] ( @idRowServiceSimogRequests int , @idGaraGgap NVARCHAR(50)
                                               , @operation NVARCHAR(50) , @statoRichiesta NVARCHAR(50)
                                               , @requestString NVARCHAR(MAX) , @responseString NVARCHAR(MAX)
                                               , @msgError NVARCHAR(1000) )
AS
BEGIN
    
	SET NOCOUNT ON
    
    UPDATE Service_SIMOG_Requests
        SET statoRichiesta = @statoRichiesta
            , numRetry = ISNULL(numRetry,0) + 1
        	, datoRichiesto = @idGaraGgap
        	, msgError = CASE
                            WHEN (ISNULL(@msgError, '') + ' --- OK') = ' --- OK' THEN ' --- OK'
                            WHEN msgError LIKE '% --- OK%' THEN @msgError
                            ELSE msgError + ' ' + @msgError
                         END
        	, outputWS = ISNULL(outputWS, '') + ' ---- ' + @responseString
        	, inputWS = ISNULL(inputWS, '') + ' ---- ' + @requestString
        WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation

END
GO
