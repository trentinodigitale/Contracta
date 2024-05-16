USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_SetErrorForSmartCigRecord]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_SetErrorForSmartCigRecord] ( @idSmartCig INT, @statoRichiesta NVARCHAR(50), @messaggioErrore NVARCHAR(MAX) )
AS
BEGIN
    
	SET NOCOUNT ON
    
    -- Annullo il documento RICHIESTA_SMART_CIG, se esiste
	UPDATE CTL_DOC
	    SET StatoFunzionale='Annullato' --, Deleted =  1
	    WHERE Id = @idSmartCig AND TipoDoc IN ('RICHIESTA_SMART_CIG')

END
GO
