USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Ggap_SetStatoToModificaLotti]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_Ggap_SetStatoToModificaLotti] ( @isFromGara BIT , @idBando INT , @idRichiestaCig INT , @idRowLotto INT,  @statoRichiesta NVARCHAR(50) )
AS
BEGIN
    IF (@isFromGara <> 0)
    BEGIN
        if (ISNULL(@idRichiestaCig,'') = '')
        BEGIN
            SELECT @idRichiestaCig = ID
                FROM CTL_DOC WITH(NOLOCK)
            	WHERE LinkedDoc = @idBando
                        AND TipoDoc = 'RICHIESTA_CIG' AND JumpCheck = 'MODIFICA' AND StatoFunzionale <> 'Annullato'
                ORDER BY Id DESC
        END

        -- Record dei lotti identificati dall'idHeader uguali all'id della richiesta cig (idRichiestaCig)
        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
            WHERE idHeader = @idRichiestaCig AND AzioneProposta = 'Update'
    END
    ELSE
    BEGIN
        -- Record deL lotto identificato dal idRow (@idRowLotto) dall'idHeader (idRichiestaCig)
        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
            WHERE idRow = @idRowLotto AND AzioneProposta = 'Update' AND idHeader = @idRichiestaCig
    END
END
GO
