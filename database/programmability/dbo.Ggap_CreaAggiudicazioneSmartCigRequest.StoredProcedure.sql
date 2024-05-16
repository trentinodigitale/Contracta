USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_CreaAggiudicazioneSmartCigRequest]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_CreaAggiudicazioneSmartCigRequest] ( @idDoc int )
AS
BEGIN
    
	SET NOCOUNT ON

    --DECLARE @idDoc INT = 472553
    DECLARE @idBandoGara INT
    DECLARE @idSmartCig NVARCHAR(MAX) = '20164'
    DECLARE @connectedUserIdUo INT = 1
    DECLARE @flagMancataAggiudicazione BIT = 0
    DECLARE @connectedUserAlias VARCHAR(MAX) = 'wsApp'

    DECLARE @dataAggiudicazione DATETIME2(7) = DATEADD(YEAR, -1, DATEADD(MONTH, -5, DATEADD(DAY, -30, GETDATE()))) -- => -13 days, -5 months, -1 year of the currentDate
    DECLARE @importoAggiudicazione INT = 0

    -- Sono obbligatori:
    --                  connectedUserAlias        --> 
    --                  connectedUserIdUo         --> Document_Bando.DirezioneEspletante
    --                  idSmartCig                --> CTL_DOC.NumeroDocumento vs Document_SIMOG_SMART_CIG.smart_cig
    --                  flagMancataAggiudicazione --> Default a "NO" ??
    
    -- Sono necessari per evitare gli errori di validazione lato GGAP:
    --                  importoAggiudicazione --> avcp_import_bandi.ImportoAggiudicazione ??
    --                  dataAggiudicazione    --> 



    --SELECT @idSmartCig = (CASE
    --                        WHEN NumeroDocumento IS NOT NULL OR NumeroDocumento <> '' THEN NumeroDocumento
    --                        ELSE '0'
    --                      END)
    --       , @idBandoGara = LinkedDoc
    --    FROM CTL_DOC WITH (NOLOCK)
    --    WHERE Id=@idDoc
    --          AND
    --          TipoDoc = 'RICHIESTA_SMART_CIG'
                
    --SELECT @connectedUserIdUo = CAST(LEFT(DirezioneEspletante, 8) AS INT) --CAST(SUBSTRING(DirezioneEspletante, 1, 8) AS INT)
    --    FROM Document_Bando WITH(NOLOCK)
    --    WHERE idHeader=@idBandoGara

    SELECT @idSmartCig                  AS idSmartCig
           ,@connectedUserIdUo          AS connectedUserIdUo
           ,@flagMancataAggiudicazione  AS flagMancataAggiudicazione
           ,@connectedUserAlias         AS connectedUserAlias
           -- AND
           ,@importoAggiudicazione      AS importoAggiudicazione
           ,@dataAggiudicazione         AS dataAggiudicazione

END

GO
