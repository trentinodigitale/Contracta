USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_DeleteRecordsForSmartCig]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests.
-- @operazione è 'consultaSmartCigGgap'
CREATE PROCEDURE [dbo].[Ggap_DeleteRecordsForSmartCig] ( @idRowServiceSimogRequests INT, @operazione NVARCHAR(50)
                                                            , @statoRichiesta NVARCHAR(50), @messaggioErrore NVARCHAR(MAX))
AS
BEGIN
    
	SET NOCOUNT ON
    
    -- Prendo l'id della richiesta smart cig
    --DECLARE @idSmartCig INT

    --    SELECT @idSmartCig = idRichiesta
    --        FROM Service_SIMOG_Requests R
    --        WHERE R.idRow= @idRowServiceSimogRequests AND operazioneRichiesta=@operazione AND isOld = 0
    

    -- Aggiorno il record nella tabella Service_SIMOG_Requests cancellando di fatto quella richiesta
    UPDATE Service_SIMOG_Requests
        SET isOld = 1
            , msgError = @messaggioErrore
            , statoRichiesta = @statoRichiesta
        FROM Service_SIMOG_Requests R
        WHERE R.idRow= @idRowServiceSimogRequests AND operazioneRichiesta=@operazione


    -- Annullo il documento RICHIESTA_SMART_CIG, se esiste
	--UPDATE CTL_DOC
	--    SET StatoFunzionale='Annullato'
	--    WHERE Id = @idSmartCig AND TipoDoc IN ('RICHIESTA_SMART_CIG')
       
END

GO
