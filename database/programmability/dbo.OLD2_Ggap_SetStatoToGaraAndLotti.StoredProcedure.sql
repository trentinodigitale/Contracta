USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_Ggap_SetStatoToGaraAndLotti]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_Ggap_SetStatoToGaraAndLotti] ( @isFromCreaGara BIT , @idBando INT , @idRichiestaCig INT , @idRowLotto INT,  @statoRichiesta NVARCHAR(50) )
AS
BEGIN
    IF (@isFromCreaGara <> 0)
    BEGIN
        -- Document Bando ==> è NECESSARIO CAMBIARE LO STATO DEL DOC BANDO_GARA ???
        --UPDATE CTL_DOC
        --    SET StatoFunzionale = @statoRichiesta
        --	WHERE Id = @idBando

        if (ISNULL(@idRichiestaCig,'') = '')
        BEGIN
            SELECT @idRichiestaCig = ID
                FROM CTL_DOC WITH(NOLOCK)
            	WHERE LinkedDoc = @idBando
                        AND TipoDoc = 'RICHIESTA_CIG'
        END

        -- Documento RichiestaCig collegato al documento Bando
        UPDATE CTL_DOC
            SET StatoFunzionale = @statoRichiesta
        	WHERE LinkedDoc = @idBando -- AND Id = @idRichiestaCig
                    AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato')
                    
        -- Record della gara identificato dall'idHeader uguale all'id della richiesta cig (idRichiestaCig)
        UPDATE Document_SIMOG_GARA
            SET StatoRichiestaGARA = @statoRichiesta
            WHERE idHeader = @idRichiestaCig

        -- Record dei lotti identificati dall'idHeader uguali all'id della richiesta cig (idRichiestaCig)
        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
            WHERE idHeader = @idRichiestaCig
    END
    ELSE
    BEGIN
        -- Record deL lotto identificato dal idRow (@idRowLotto) dall'idHeader (idRichiestaCig)
        UPDATE Document_SIMOG_LOTTI
            SET StatoRichiestaLOTTO = @statoRichiesta
            WHERE idRow = @idRowLotto
                    AND idHeader = @idRichiestaCig
    END
END


--  SELECT Id, NumeroDocumento, StatoFunzionale FROM CTL_DOC WITH(NOLOCK) WHERE (LinkedDoc=476196 AND TipoDoc='RICHIESTA_CIG') OR Id=476196
--  
--  SELECT idrow, idHeader, StatoRichiestaGARA FROM Document_SIMOG_GARA WITH(NOLOCK) WHERE idHeader = 476199
--  
  --SELECT idrow, idHeader, StatoRichiestaLOTTO, idLottoEsterno FROM Document_SIMOG_LOTTI WITH(NOLOCK) WHERE idRow = 1329 AND idHeader = 476199
--  
--  SELECT idrow, idHeader, StatoRichiestaLOTTO, idLottoEsterno FROM Document_SIMOG_LOTTI WITH(NOLOCK) WHERE idHeader = 476199

GO
