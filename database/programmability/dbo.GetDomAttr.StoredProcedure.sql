USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetDomAttr]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetDomAttr](@vcAttributo VARCHAR(50), @vcCodice VARCHAR(20),@vcLingua VARCHAR(10)) 
AS
DECLARE @idztIdTid      INT
DECLARE @vcSQL          VARCHAR(8000)
SELECT @idztIdTid=dztIdTid 
  FROM DizionarioAttributi
 WHERE dztNome = @vcAttributo 
   AND dztDeleted=0
IF @idztIdTid IS NULL
   BEGIN
      RAISERROR ('Errore: Attributo inesistente  - (GetDomAttr) ', 16, 1) 
        RETURN 99
   END
IF NOT EXISTS (SELECT * FROM TipiDati WHERE IdTid=@idztIdTid AND tidDeleted=0 AND tidTipoDom='C')
   BEGIN
      RAISERROR ('Errore: Tipi Dato inesistente  - (GetDomAttr) ', 16, 1) 
        RETURN 99
   END
SET @vcSQL='SELECT * FROM TipiDatiRange, Descs'+@vcLingua+'  WHERE tdrIdTid='+CAST(@idztIdTid AS VARCHAR(20))+' AND tdrIdDsc=IdDsc AND tdrDeleted = 0 '
SET @vcSQL=@vcSQL+CASE @vcCodice   WHEN '' THEN ' '
                                    ELSE ' AND tdrCodice = '''+@vcCodice+''' '      
                      END
EXEC (@vcSQL + ' ORDER BY CAST(tdrCodice AS INT)')
IF @@ERROR<>0
   BEGIN
        RETURN 99
   END
GO
