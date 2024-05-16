USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_GetIdSmartCigGgap]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_GetIdSmartCigGgap] ( @idBandoGara int )
AS
BEGIN
    SELECT  CAST(CASE WHEN NumeroDocumento NOT LIKE '%[^0-9]%' THEN NumeroDocumento END AS INT) AS idSmartCigGgap -- L'id che GGAP restituisce
    	FROM CTL_DOC WITH (NOLOCK)
    	WHERE LinkedDoc = @idBandoGara
    			AND StatoFunzionale <> 'Annullato'
    			AND TipoDoc = 'RICHIESTA_SMART_CIG'
    			AND Deleted = 0
END
GO
