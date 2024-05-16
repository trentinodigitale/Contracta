USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetAttributo]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetAttributo](@CodAttributo AS INTeger, @Lingua AS VARCHAR(10)) 
as
DECLARE @dztNome      AS VARCHAR(30)
DECLARE @tidTipoDom   AS VARCHAR(5)
DECLARE @IdTid        AS INTeger
DECLARE @strSql       AS VARCHAR(1000)
set @dztNome           = NULL
set @tidTipoDom        = NULL
IF @Lingua IS NULL or @Lingua = ''
    begin
          raiserror ('Parametro @Lingua non valido (GetAttributo)', 16, 1) 
          return (99)
    end
IF @CodAttributo IS NULL or @CodAttributo = 0
    begin
          raiserror ('Parametro @CodAttributo non valido (GetAttributo)', 16, 1) 
          return (99)
    end
IF @Lingua not in ('I', 'UK', 'E', 'FRA')
    begin
          raiserror ('Lingua "%s" non gestita (GetAttributo)', 16, 1, @Lingua) 
          return (99)
    end
SELECT @dztNome = dztNome, @IdTid = IdTid, @tidTipoDom = tidTipoDom
  FROM DizionarioAttributi, TipiDati
 WHERE dztIdTid = IdTid
   AND IdDzt = @CodAttributo
IF @dztNome IS NULL
   begin
          raiserror ('Attributo "%d" non trovato in DizionarioAttributi (GetAttributo)', 16, 1, @CodAttributo) 
          return (99)
   end
/*
   Nel caso della Descrizione Articolo trattiamo l'attributo come se fosse a dominio chiuso
*/
IF @dztNome = 'Descrizione Articolo'
   begin
        set @strSql = 'SELECT NULL AS CodiceEsterno, artIdDscDescrizione AS CodiceInterno, dscTesto AS Descrizione, ' +
                      ' NULL AS CodiceEsternoPadre, NULL AS CodiceInternoPadre, cast (0 AS bit) AS Gerarchia ' +
                      ' FROM Articoli, Descs' +  @Lingua + ' WHERE artIdDscDescrizione = IdDsc ' + 
                      ' ORDER BY IdArt '
        execute  (@strSql)
        return (0)
   end
/*
     x la natura giuridica restituiamo la colonna tdrIdDsc invece di IdTdr
*/
IF @dztNome = 'NAGI'
   begin
        set @strSql = 'SELECT NULL AS CodiceEsterno, tdrIdDsc AS CodiceInterno, dscTesto AS Descrizione, ' +
                      ' NULL AS CodiceEsternoPadre, NULL AS CodiceInternoPadre, cast (0 AS bit) AS Gerarchia ' +
                      ' FROM TipiDatiRange, Descs' +  @Lingua + ' WHERE tdrIdDsc = IdDsc ' + 
                      ' AND tdrIdtid = ' + cast(@idtid AS VARCHAR(10)) + ' ORDER BY tdrRelOrdine'
        execute  (@strSql)
        return (0)
   end
/*
    Domini Chiusi
*/
IF  @tidTipoDom = 'C'
    begin 
        set @strSql = 'SELECT NULL AS CodiceEsterno, idTdr AS CodiceInterno, dscTesto AS Descrizione, ' +
                      ' NULL AS CodiceEsternoPadre, NULL AS CodiceInternoPadre, cast (0 AS bit) AS Gerarchia ' +
                      ' FROM TipiDatiRange, Descs' +  @Lingua + ' WHERE tdrIdDsc = IdDsc ' + 
                      ' AND tdrIdtid = ' + cast(@idtid AS VARCHAR(10)) + ' ORDER BY tdrRelOrdine'
        execute  (@strSql)
        return (0)
    end   
/*
   Domini Gerarchici
*/
IF @tidTipoDom = 'G'
   begin 
        set @strSql = 'SELECT a.dgCodiceEsterno AS CodiceEsterno, a.dgCodiceInterno AS CodiceInterno, dscTesto AS Descrizione, ' +
                      ' b.dgCodiceEsterno AS CodiceEsternoPadre, b.dgCodiceInterno AS CodiceInternoPadre, ' + 
                      ' cast (1 AS bit) AS Gerarchia ' +
                      ' FROM DominiGerarchici a, DominiGerarchici b, Descs' +  @Lingua + 
                      ' c WHERE a.dgIdDsc = c.IdDsc ' + 
                      ' AND a.dgTipoGerarchia = ' + cast(@idtid AS VARCHAR(10)) + 
                      ' AND b.dgTipoGerarchia = ' + cast(@idtid AS VARCHAR(10)) + 
                      ' AND b.dgPath = left(a.dgPath, (a.dgLenPathPadre))' +
                      ' ORDER BY a.dgPath'
        execute  (@strSql)
        return (0)
   end  
GO
