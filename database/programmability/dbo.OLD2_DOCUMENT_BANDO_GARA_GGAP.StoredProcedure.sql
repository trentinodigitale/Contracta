USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DOCUMENT_BANDO_GARA_GGAP]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD2_DOCUMENT_BANDO_GARA_GGAP] ( @DocName NVARCHAR(50) , @Section NVARCHAR(50) , @IdDoc INT , @idUser INT )
AS
BEGIN
    
	SET NOCOUNT ON

    DECLARE @StatoDoc NVARCHAR(20) = '' -- Tiene traccia dello stato del doc RICHIESTA_CIG
    DECLARE @Deleted BIT = 0 -- Tiene traccia della cancellazione logica del doc RICHIESTA_CIG
    DECLARE @idDocR INT = -1 -- Tiene traccia dell'id del doc RICHIESTA_CIG

    --DECLARE @idDoc INT = 472509 -- 475510

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


    DECLARE @isSimogGgap BIT = CASE 
                                WHEN (SELECT CHARINDEX('SIMOG_GGAP', (select DZT_ValueDef from LIB_Dictionary WITH(NOLOCK) where dzt_name = 'SYS_MODULI_GRUPPI'))) > 1 THEN 1
                                ELSE 0
                               END


    
    SELECT @isSimogGgap AS isSimogGgap, * FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader=@IdDoc AND DSE_ID='GGAP'
    

    -- Per controllare se il modulo 'SIMOG_GGAP' c'è all'interno della stringa 'SYS_MODULI_GRUPPI'
    --SELECT CHARINDEX('SIMOG_GGAP', (select DZT_ValueDef from LIB_Dictionary WITH(NOLOCK) where dzt_name = 'SYS_MODULI_GRUPPI'))

END

GO
