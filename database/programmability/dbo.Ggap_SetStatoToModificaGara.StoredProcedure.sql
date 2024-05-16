USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_SetStatoToModificaGara]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_SetStatoToModificaGara] ( @idBando INT , @idRowServiceSimogRequests INT,  @statoRichiesta NVARCHAR(50) /* @isFromCreaGara BIT */ )
AS
BEGIN
    
    DECLARE @idRichiestaCig INT
        
        SELECT TOP (1) @idRichiestaCig = ID
            FROM CTL_DOC WITH(NOLOCK)
            WHERE LinkedDoc = @idBando
                    AND TipoDoc = 'RICHIESTA_CIG' AND JumpCheck = 'MODIFICA' AND StatoFunzionale <> 'Annullato'
            ORDER BY Id DESC
                    
    -- Record della gara identificato dall'idHeader uguale all'id della richiesta cig (idRichiestaCig)
    UPDATE Document_SIMOG_GARA
        SET StatoRichiestaGARA = @statoRichiesta
        FROM Document_SIMOG_GARA G
                INNER JOIN Service_SIMOG_Requests R WITH (NOLOCK) ON G.idRow = R.idRichiesta 
        WHERE R.idrow = @idRowServiceSimogRequests
                AND R.statoRichiesta NOT IN ('ErroreLogin','RicevutoErrore','Errore')
                AND R.isOld = 0
                AND R.operazioneRichiesta IN ('garaModificaGgap')
                AND G.idHeader = @idRichiestaCig
                AND G.AzioneProposta = 'Update'
END
GO
