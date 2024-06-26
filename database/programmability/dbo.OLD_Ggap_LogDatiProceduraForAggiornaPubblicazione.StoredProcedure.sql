USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Ggap_LogDatiProceduraForAggiornaPubblicazione]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @operation dovrebbe contenere garaAggiornaPubblicazioneGgap
CREATE PROCEDURE [dbo].[OLD_Ggap_LogDatiProceduraForAggiornaPubblicazione] ( @idRichiestaCig int , @idGaraGgap NVARCHAR(50)
                                                                      , @operation NVARCHAR(50) , @statoRichiesta NVARCHAR(50)
                                                                      , @requestString NVARCHAR(MAX) , @responseString NVARCHAR(MAX)
                                                                      , @msgError NVARCHAR(1000) )
AS
BEGIN

    --  SELECT TOP (10) * FROM Service_SIMOG_Requests ORDER BY idRow DESC
    --  SELECT TOP (10) * FROM Service_SIMOG_Requests WHERE idRichiesta=478562 ORDER BY idRow DESC
    
	SET NOCOUNT ON

    -- Recupero l'IdPfu da inserire nella Service_SIMOG_Requests
    DECLARE @idPfuRup INT
        SELECT @idPfuRup = IdPfu FROM CTL_DOC WHERE Id = @idRichiestaCig

    -- Se non c'è stato un errore allora imposto OK nel campo di errore della Service_SIMOG_Requests
    IF (ISNULL(@msgError, '') = '')
        SET @msgError = ' --- OK'

    -- Annullo i precedenti record nella Service_SIMOG_Requests
    UPDATE Service_SIMOG_Requests
        SET statoRichiesta='Annullato'
        WHERE idRichiesta=@idRichiestaCig
                AND operazioneRichiesta='garaAggiornaPubblicazioneGgap'
                AND datoRichiesto=@idGaraGgap
                AND statoRichiesta NOT IN ('Annullato')
    
    -- Inserisco un nuovo record di log
    INSERT INTO Service_SIMOG_Requests ( idRichiesta, operazioneRichiesta, statoRichiesta, datoRichiesto, msgError, numRetry, inputWS, outputWS, idPfuRup )
        VALUES ( @idRichiestaCig, @operation, @statoRichiesta, @idGaraGgap, @msgError, 1, @requestString, @responseString, @idPfuRup )
        
END
GO
