USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Ggap_GetIsGaraPubblicato]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Ggap_GetIsGaraPubblicato] ( @idDocBando INT )
AS
BEGIN
    --DECLARE @idDocBando INT = 478556
    DECLARE @isPubblicato BIT = 0

    SELECT @isPubblicato = ( CASE
                                  WHEN [Value] = 'true' THEN 1
                                  WHEN [Value] = 'false' THEN 0
                                  WHEN ISNULL([Value], '') = '' THEN 0
                                  ELSE 0
                             END)
        FROM CTL_DOC_Value WITH(NOLOCK)
        WHERE IdHeader = @idDocBando
                AND DSE_ID = 'GGAP'
    	        AND DZT_Name = 'EsitoPubblicazione'

    SELECT @isPubblicato
END
GO
