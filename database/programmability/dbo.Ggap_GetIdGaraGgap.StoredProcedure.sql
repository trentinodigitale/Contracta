USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_GetIdGaraGgap]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- @idRowServiceSimogRequests contiene il valore del campo idRow, che si trova nella tabella Service_SIMOG_Requests, per il record 
--  relativo al Lotto (lottoInserisciGgap)
CREATE PROCEDURE [dbo].[Ggap_GetIdGaraGgap] ( @idRowServiceSimogRequests INT = -1, @idRichiestaCig INT = -1 )
AS
BEGIN
    
	SET NOCOUNT ON

    --DECLARE @idRowServiceSimogRequests INT = 212323

    IF (@idRowServiceSimogRequests <> -1 AND @idRichiestaCig = -1)
    BEGIN

        -- Prendo l'id della RICHIESTA_CIG e del BANDO_GARA
        --DECLARE @idBando INT -- = 476196

        SELECT  CAST(CASE WHEN D.NumeroDocumento NOT LIKE '%[^0-9]%' THEN D.NumeroDocumento END AS INT)
                --@idBando = D.LinkedDoc -- BANDO_GARA
                --, @idRichiestaCig = D.Id -- RICHIESTA_CIG
                --, @idBando = BANDO.idHeader -- BANDO_GARA
            FROM Document_SIMOG_LOTTI L WITH (NOLOCK)
                    LEFT OUTER JOIN Service_SIMOG_Requests R WITH (NOLOCK)
                        ON L.idrow = R.idRichiesta
                            AND R.operazioneRichiesta IN ('lottoInserisciGgap','lottoModificaGgap') -- 'garaInserisciGgap', 
                            AND R.isOld = 0
                    INNER JOIN CTL_DOC D WITH (NOLOCK) ON L.idheader = D.id
                    --LEFT JOIN Document_Bando BANDO WITH (NOLOCK) ON D.LinkedDoc = BANDO.idHeader
            WHERE R.idRow = @idRowServiceSimogRequests
        
        --SELECT CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT)
        --    FROM CTL_DOC WITH(NOLOCK)
        --    WHERE LinkedDoc=@idBando AND TipoDoc='RICHIESTA_CIG'
    END
    ELSE -- IF (@idRowServiceSimogRequests = -1 AND @idRichiestaCig <> -1)
    BEGIN
        SELECT CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT)
            FROM CTL_DOC WITH(NOLOCK)
            WHERE Id=@idRichiestaCig AND TipoDoc='RICHIESTA_CIG'
    END

END

GO
