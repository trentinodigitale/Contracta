USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Ggap_InsertOrUpdateIdGara]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_Ggap_InsertOrUpdateIdGara] ( @idDoc INT, @idGara NVARCHAR(MAX) , @statoRichiesta NVARCHAR(MAX), @idRowServiceSimogRequests INT )
AS
BEGIN

	SET NOCOUNT ON

    --DECLARE @NumDoc NVARCHAR(50)
    --SELECT @NumDoc = NumeroDocumento FROM CTL_DOC WITH(NOLOCK) WHERE LinkedDoc = @idDoc AND TipoDoc='RICHIESTA_CIG'
    --IF (ISNULL(@NumDoc, '') = '')

	UPDATE CTL_DOC
	    SET NumeroDocumento = @idGara
            , StatoFunzionale = @statoRichiesta
	    WHERE LinkedDoc = @idDoc AND TipoDoc='RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato') AND Deleted = 0

    UPDATE Document_SIMOG_GARA
        SET StatoRichiestaGARA = @statoRichiesta
        WHERE idHeader IN (SELECT Id FROM CTL_DOC WHERE LinkedDoc = @idDoc AND TipoDoc='RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato'))

    UPDATE Service_SIMOG_Requests
        SET datoRichiesto = @idGara
            --, statoRichiesta = @statoRichiesta -- Se metto questo potrebbe esserci una concorrenza con il processo di finalizza (SIMOG-FINALIZZA)
        WHERE idRow = @idRowServiceSimogRequests AND operazioneRichiesta = 'garaInserisciGgap'

            
--	    UPDATE CTL_DOC
--	        SET NumeroDocumento = NULL
--	        WHERE LinkedDoc = 476023 AND TipoDoc='RICHIESTA_CIG'

END
GO
