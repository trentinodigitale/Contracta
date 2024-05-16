USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_LogLottoInModifica]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- @operation dovrebbe contenere 'lottoModificaGgap'
CREATE PROCEDURE [dbo].[Ggap_LogLottoInModifica] ( @idRowServiceSimogRequests int , @idLottoGgap NVARCHAR(50)
                                                 , @operation NVARCHAR(50) , @statoRichiesta NVARCHAR(50)
                                                 , @requestString NVARCHAR(MAX) , @responseString NVARCHAR(MAX)
                                                 , @msgError NVARCHAR(1000) )
AS
BEGIN
    
	SET NOCOUNT ON
    
    IF (ISNULL(@msgError, '') = '')
    BEGIN
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta
                , numRetry = ISNULL(numRetry,0) + 1
            	, datoRichiesto = @idLottoGgap
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
END
GO
