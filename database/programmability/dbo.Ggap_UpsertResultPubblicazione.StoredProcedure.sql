USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_UpsertResultPubblicazione]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_UpsertResultPubblicazione] ( @idDocBando INT, @operation NVARCHAR(50), @isPubblicato BIT )
AS
BEGIN
    --  DECLARE @idDocBando INT = 478556
    --  SELECT * FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader = @idDocBando AND DSE_ID = 'GGAP' AND DZT_Name = 'EsitoPubblicazione'
    --  UPDATE CTL_DOC_Value SET [Value] = 'false' WHERE IdHeader = @idDocBando AND DSE_ID = 'GGAP' AND DZT_Name = 'EsitoPubblicazione'

    DECLARE @esitoPubblicazione NVARCHAR(10)

    SET @esitoPubblicazione = CASE
                                WHEN @isPubblicato = 1 THEN 'true'
                                ELSE 'false'
                              END
    
    IF EXISTS ( SELECT IdRow FROM CTL_DOC_Value WITH(NOLOCK) WHERE IdHeader = @idDocBando AND DSE_ID = 'GGAP' AND DZT_Name = 'EsitoPubblicazione' )
    BEGIN
        UPDATE CTL_DOC_Value
            SET [Value] = @esitoPubblicazione
            WHERE IdHeader = @idDocBando AND DSE_ID = 'GGAP' AND DZT_Name = 'EsitoPubblicazione'
    END
    ELSE
    BEGIN
        INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, [Row], DZT_Name, [Value] )
            VALUES ( @idDocBando, 'GGAP', 0, 'EsitoPubblicazione', @esitoPubblicazione )
    END
END
GO
