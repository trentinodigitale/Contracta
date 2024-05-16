USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_InsertOrUpdateIdLotto]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Ggap_InsertOrUpdateIdLotto] ( @idHeader INT, @idLottoEsterno INT, @idRow INT , @statoRichiesta NVARCHAR(MAX), @idRowServiceSimogRequests INT )
AS
BEGIN

	SET NOCOUNT ON
    
    --DECLARE @idLottoGgap NVARCHAR(50)
    --SELECT @idLottoGgap = idLottoEsterno
    --    FROM Document_SIMOG_LOTTI WITH(NOLOCK)
    --    WHERE idHeader = @idHeader AND idRow = @idRow
    --IF (ISNULL(@idLottoGgap, '') = '')

    UPDATE Document_SIMOG_LOTTI
        SET idLottoEsterno = @idLottoEsterno
            , StatoRichiestaLOTTO = @statoRichiesta
        WHERE idHeader = @idHeader AND idRow = @idRow

    UPDATE Service_SIMOG_Requests
        SET datoRichiesto = @idLottoEsterno
            --, statoRichiesta = @statoRichiesta -- Se metto questo potrebbe esserci una concorrenza con il processo di finalizza (SIMOG-FINALIZZA)
        WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = 'lottoInserisciGgap'
            
--	    UPDATE Document_SIMOG_LOTTI
--	        SET idLottoEsterno = NULL
--          WHERE idHeader = 476026 AND idRow = 1318


    --SELECT idLottoEsterno, *
    --    FROM Document_SIMOG_LOTTI WITH(NOLOCK)
    --    WHERE idHeader = 476199 AND idRow = 1329

    --SELECT datoRichiesto, *
    --    FROM Service_SIMOG_Requests WITH(NOLOCK)
    --    WHERE idRow = 212323 AND operazioneRichiesta = 'lottoInserisciGgap'

END
GO
