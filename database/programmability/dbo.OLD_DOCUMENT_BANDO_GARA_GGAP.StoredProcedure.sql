USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_BANDO_GARA_GGAP]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_DOCUMENT_BANDO_GARA_GGAP] ( @DocName NVARCHAR(50) , @Section NVARCHAR(50) , @IdDoc INT , @idUser INT )
AS
BEGIN
    
	SET NOCOUNT ON

    DECLARE @StatoDoc NVARCHAR(20) = '' -- Tiene traccia dello stato del doc RICHIESTA_CIG
    DECLARE @Deleted BIT = 0 -- Tiene traccia della cancellazione logica del doc RICHIESTA_CIG
    DECLARE @idDocR INT = -1 -- Tiene traccia dell'id del doc RICHIESTA_CIG

    --DECLARE @idDoc INT = 478310

    IF EXISTS( SELECT Id, StatoFunzionale, Deleted, JumpCheck, Caption FROM CTL_DOC WITH (NOLOCK) WHERE TipoDoc = 'RICHIESTA_CIG' AND LinkedDoc = @idDoc )
    BEGIN
        SELECT TOP 1 @StatoDoc=StatoFunzionale, @idDocR=Id, @Deleted=Deleted
            FROM CTL_DOC WITH (NOLOCK)
            WHERE TipoDoc = 'RICHIESTA_CIG' AND LinkedDoc = @idDoc --AND StatoFunzionale NOT IN ('Annullato')
            ORDER BY Id DESC
    END

    UPDATE CTL_DOC_Value SET [VALUE]=@StatoDoc WHERE IdHeader = @IdDoc AND DSE_ID = 'GGAP' AND DZT_Name='StatoDoc'
    UPDATE CTL_DOC_Value SET [VALUE]=@Deleted WHERE IdHeader = @IdDoc AND DSE_ID = 'GGAP' AND DZT_Name='Deleted'
    UPDATE CTL_DOC_Value SET [VALUE]=@idDocR WHERE IdHeader = @IdDoc AND DSE_ID = 'GGAP' AND DZT_Name='idDocR'


    -- Variabile che contiene info riguardo alla presenza del modulo SIMOG_GGAP nella SYS_MODULI_GRUPPI, ossia se il modulo è attivo o no
    DECLARE @isSimogGgap NVARCHAR(50) = CASE 
                                            WHEN (SELECT CHARINDEX('SIMOG_GGAP', (SELECT DZT_ValueDef FROM LIB_Dictionary WITH (NOLOCK) WHERE dzt_name = 'SYS_MODULI_GRUPPI'))) > 1
                                               THEN 1
                                            ELSE 0
                                        END


    -- Prendo l'id che GGAP ritorna nel creare la gara (l'id gara di GGAP)
    DECLARE @idGaraGgap NVARCHAR(50)
    SELECT TOP (1) @idGaraGgap=NumeroDocumento FROM CTL_DOC WITH (NOLOCK)
        WHERE LinkedDoc=@IdDoc AND TipoDoc IN ('RICHIESTA_CIG') AND StatoFunzionale='Inviato' ORDER BY Id DESC


    -- Ritorno i dati
    SELECT * FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@IdDoc AND DSE_ID='GGAP'
        UNION
    SELECT -1 AS IdRow, @IdDoc AS IdHeader, 'GGAP' AS DSE_ID, 0 AS [Row], 'idGaraGgap' AS DZT_Name , @idGaraGgap AS [Value]
        UNION
    SELECT -2 AS IdRow, @IdDoc AS IdHeader, 'GGAP' AS DSE_ID, 0 AS [Row], 'isSimogGgap' AS DZT_Name , @isSimogGgap AS [Value]
            
    
END

GO
