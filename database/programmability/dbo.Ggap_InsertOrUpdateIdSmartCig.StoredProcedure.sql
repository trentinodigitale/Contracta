USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_InsertOrUpdateIdSmartCig]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Ggap_InsertOrUpdateIdSmartCig] ( @idSmartCig INT, @idSmartCigGgap NVARCHAR(MAX), @statoFunzionale NVARCHAR(MAX) )
AS
BEGIN

	SET NOCOUNT ON
    
    --DECLARE @NumDoc NVARCHAR(50)
    --SELECT @NumDoc = NumeroDocumento FROM CTL_DOC WITH(NOLOCK) WHERE Id = @idSmartCig AND TipoDoc='RICHIESTA_SMART_CIG'
    --IF (ISNULL(@NumDoc, '') = '')

    UPDATE CTL_DOC
        SET NumeroDocumento = @idSmartCigGgap
            , StatoFunzionale = @statoFunzionale -- 'Inviato'
        WHERE Id = @idSmartCig AND TipoDoc='RICHIESTA_SMART_CIG'

END
GO
