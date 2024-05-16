USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_SetStatoToRichiestaCig]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_SetStatoToRichiestaCig] (@idRowServiceSimogRequests INT, @statoFunzionale NVARCHAR(50)
                                                    , @isFromGara BIT, @idBando INT, @idRichiestaCig INT )
AS
BEGIN
    IF (@isFromGara <> 0) -- Ho l'id del doc Bando se provengo da una richiesta di CreaGara oppure ModificaGara
    BEGIN
        --IF (ISNULL(@idRichiestaCig, -1) = -1)
        --BEGIN
        --    SELECT TOP (1) @idRichiestaCig = Id
        --        FROM CTL_DOC WITH(NOLOCK)
        --    	WHERE LinkedDoc = @idBando
        --                AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato') AND JumpCheck = 'MODIFICA'
        --        ORDER BY Id DESC
        --END

        -- Documento RichiestaCig collegato al documento Bando
        UPDATE CTL_DOC
            SET StatoFunzionale = @statoFunzionale
        	WHERE Id IN (SELECT TOP (1) Id
                            FROM CTL_DOC
                            WHERE LinkedDoc = @idBando
                                    AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato') AND JumpCheck = 'MODIFICA'
                            ORDER BY Id DESC)
    END
    ELSE -- Altrimenti ho l'id del doc Richiesta Cig se è il caso per CreaLotto oppure ModificaLotto
    BEGIN
        --IF (ISNULL(@idBando, -1) = -1)
        --BEGIN
        --    SELECT @idBando = LinkedDoc
        --        FROM CTL_DOC WITH(NOLOCK)
        --    	WHERE Id = @idRichiestaCig
        --                AND TipoDoc = 'RICHIESTA_CIG'
        --END

        -- Documento RichiestaCig collegato al documento Bando
        UPDATE CTL_DOC
            SET StatoFunzionale = @statoFunzionale
        	WHERE Id = @idRichiestaCig
                    AND TipoDoc = 'RICHIESTA_CIG' AND StatoFunzionale NOT IN ('Annullato')
    END
END
GO
