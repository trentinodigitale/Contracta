USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_LogSmartCig]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Ggap_LogSmartCig] ( @idSmartCig int , @idRowServiceSimogRequests INT,
                                          @operation NVARCHAR(50) , @statoRichiesta NVARCHAR(50) ,
                                          @requestString NVARCHAR(MAX) , @responseString NVARCHAR(MAX) ,
                                          @msgError NVARCHAR(1000) )
AS
BEGIN
    
	SET NOCOUNT ON

    -- Tabella Service_SIMOG_Requests
    IF(ISNULL(@idRowServiceSimogRequests,'') = '')
    BEGIN
        -- Inserisco una nuova richiesta
        INSERT INTO Service_SIMOG_Requests
        		(idRichiesta, operazioneRichiesta, statoRichiesta, msgError, outputWS, inputWS, isOld, dateIn)
        	VALUES (@idSmartCig, @operation, @statoRichiesta, @msgError, @responseString, @requestString, 0, GETDATE())

		DECLARE @newId INT = SCOPE_IDENTITY()

        -- Annullo le precedenti richieste
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = 'Annullato', msgError = CONCAT('Annullato perché si inserisce una nuova richiesta con idRow= ', @newId), isOld = 1
            WHERE idRichiesta = @idSmartCig AND operazioneRichiesta = @operation AND idRow <> @newId AND statoRichiesta NOT IN ('Annullato','Errore')
    END
    ELSE -- Altrimenti @idRowServiceSimogRequests è valorizzato
    BEGIN
        UPDATE Service_SIMOG_Requests
            SET statoRichiesta = @statoRichiesta, msgError = @msgError, outputWS = @responseString, inputWS = @requestString, isOld = 0
            WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation

        SELECT @idSmartCig = idRichiesta
            FROM Service_SIMOG_Requests
            WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = @operation
    END


    IF(ISNULL(@msgError,'') <> '')
    BEGIN
        SET @msgError = @msgError  + ' - Time: ' + CONVERT(NVARCHAR, GETDATE(), 127)
    END

    -- Tabella Document_SIMOG_SMART_CIG
    UPDATE Document_SIMOG_SMART_CIG
    	SET EsitoControlli = @msgError
        WHERE idHeader = @idSmartCig

END
GO
