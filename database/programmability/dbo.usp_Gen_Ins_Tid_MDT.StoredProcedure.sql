USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_Tid_MDT]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Gen_Ins_Tid_MDT] (
  @IdTid INT
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)

AS

DECLARE @IdTidNew                       INT
DECLARE @tidNome                        VARCHAR(255)
DECLARE @tidTipoMem                     VARCHAR(20)
DECLARE @tidTipoDom                     VARCHAR(20)
DECLARE @tidSistema                     VARCHAR(20)
DECLARE @tidOper                        VARCHAR(20)
DECLARE @tidQuery                       VARCHAR(8000)

DECLARE @tdrRelOrdine                   VARCHAR(10)
DECLARE @tdrCodice                      VARCHAR(100) 
DECLARE @tdrCodiceEsterno               VARCHAR(100)
DECLARE @tdrCodiceRaccordo              VARCHAR(100)

DECLARE @dgCodiceInterno                VARCHAR(150)
DECLARE @dgCodiceEsterno                VARCHAR(150)
DECLARE @dgPath                         VARCHAR(255)
DECLARE @dgLivello                      VARCHAR(10)
DECLARE @dgFoglia                       VARCHAR(10)
DECLARE @dgLenPathPadre                 VARCHAR(10)
DECLARE @dgCodiceRaccordo               VARCHAR(150)

DECLARE @ITA                            VARCHAR(255)
DECLARE @UK                             VARCHAR(255)
DECLARE @ES                             VARCHAR(255)
DECLARE @FRA                            VARCHAR(255)

--

IF NOT EXISTS (SELECT * FROM TipiDati WHERE IdTid = @IdTid)
BEGIN
        RAISERROR ('TipoDato [%d] non trovato', 16, 1, @IdTid)
        RETURN 99
END
SELECT @tidNome     = CASE WHEN tidNome IS NOT NULL THEN '''' + RTRIM(tidNome) + '''' ELSE 'NULL' END
     , @tidTipoMem  = ISNULL(CAST(tidTipoMem AS VARCHAR(10)), 'NULL')
     , @tidTipoDom  = CASE WHEN tidTipoDom IS NOT NULL THEN '''' + tidTipoDom + '''' ELSE 'NULL' END
     , @tidSistema  = ISNULL(CAST(tidSistema AS VARCHAR(10)), 'NULL')
     , @tidOper     = ISNULL(CAST(tidOper AS VARCHAR(10)), 'NULL')
     , @tidQuery    =  CASE WHEN tidQuery IS NOT NULL THEN '''' + REPLACE(CAST(tidQuery AS VARCHAR(8000)), '''', '''''') + '''' ELSE 'NULL' END
  FROM TipiDati
 WHERE IdTid = @IdTid 

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdTid                        INT'
        PRINT 'DECLARE @IdDsc                        INT'
        PRINT 'DECLARE @IdDg                         INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END


IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET @IdTid = ' + CAST (@IdTid AS VARCHAR)
        PRINT ' '
        PRINT 'INSERT INTO TipiDati (IdTid, tidNome, tidTipoMem, tidTipoDom, tidSistema, tidOper, tidQuery)'
        PRINT '     VALUES (@IdTid, ' + @tidNome + ', ' + @tidTipoMem + ', ' + @tidTipoDom 
                              + ', ' + @tidSistema + ', ' + @tidOper + ', ' + @tidQuery + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" TipiDati'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
END
ELSE
BEGIN
        PRINT ' '
        PRINT 'SELECT @IdTid = MAX(IdTid)'
        PRINT '  FROM TipiDati'
        PRINT ' '
        PRINT 'SET @IdTid = @IdTid + 1'
        PRINT ' '
        PRINT 'INSERT INTO TipiDati (IdTid, tidNome, tidTipoMem, tidTipoDom, tidSistema, tidOper, tidQuery)'
        PRINT '     VALUES (@IdTid, ' + @tidNome + ', ' + @tidTipoMem + ', ' + @tidTipoDom 
                              + ', ' + @tidSistema + ', ' + @tidOper + ', ' + @tidQuery + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" TipiDati'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
END

IF @tidTipoDom = '''A''' 
        GOTO ExitProc
ELSE

IF @tidTipoDom = '''G''' 
        GOTO TipoDomG

/* Domini Chiusi */

DECLARE crs CURSOR STATIC FOR SELECT ISNULL(CAST(tdrRelOrdine AS VARCHAR(10)), 'NULL') 
                                   , CASE WHEN tdrCodice IS NOT NULL THEN '''' + tdrCodice + '''' ELSE 'NULL' END
                                   , CASE WHEN tdrCodiceEsterno IS NOT NULL THEN '''' + tdrCodiceEsterno + '''' ELSE 'NULL' END
                                   , CASE WHEN tdrCodiceRaccordo IS NOT NULL THEN '''' + tdrCodiceRaccordo + '''' ELSE 'NULL' END
                                   , CASE WHEN ITA.dscTesto IS NOT NULL THEN '''' + REPLACE(ITA.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                   , CASE WHEN UK.dscTesto IS NOT NULL THEN '''' + REPLACE(UK.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                   , CASE WHEN ES.dscTesto IS NOT NULL THEN '''' + REPLACE(ES.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                   , CASE WHEN FRA.dscTesto IS NOT NULL THEN '''' + REPLACE(FRA.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                FROM TipiDatiRange
                                   , DescsI ITA
                                   , DescsUK UK
                                   , DescsE ES
                                   , DescsFRA FRA
                               WHERE tdrIdDsc = ITA.IdDsc
                                 AND tdrIdDsc = UK.IdDsc
                                 AND tdrIdDsc = ES.IdDsc
                                 AND tdrIdDsc = FRA.IdDsc
                                 AND tdrIdTid = @IdTid
                                 AND tdrDeleted = 0
                              ORDER BY tdrRelOrdine
 
OPEN crs
 
 
FETCH NEXT FROM crs INTO @tdrRelOrdine, @tdrCodice, @tdrCodiceEsterno, @tdrCodiceRaccordo, 
                         @ITA, @UK, @ES, @FRA

WHILE @@FETCH_STATUS = 0
BEGIN
        PRINT ' '
        PRINT 'INSERT INTO DescsI (dscTesto)'
        PRINT '     VALUES (' + @ITA + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'SET @IdDsc = @@IDENTITY'
        PRINT ' '
        PRINT 'INSERT INTO DescsUK (IdDsc, dscTesto)'
        PRINT '     VALUES (@IdDsc, ' + @UK + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'INSERT INTO DescsE (IdDsc, dscTesto)'
        PRINT '     VALUES (@IdDsc, ' + @ES + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'INSERT INTO DescsFRA (IdDsc, dscTesto)'
        PRINT '     VALUES (@IdDsc, ' + @FRA + ')'
        PRINT ' '
        PRINT ' '

        PRINT 'INSERT INTO TipiDatiRange (tdrIdTid, tdrIdDsc, tdrRelOrdine, tdrCodice, tdrCodiceEsterno, tdrCodiceRaccordo)'
        PRINT '     VALUES (@IdTid, @IdDsc, ' + @tdrRelOrdine + ', ' + @tdrCodice + ', ' + @tdrCodiceEsterno + ', ' + @tdrCodiceRaccordo + ')'
        PRINT ' '
        PRINT ' '

        FETCH NEXT FROM crs INTO @tdrRelOrdine, @tdrCodice, @tdrCodiceEsterno, @tdrCodiceRaccordo, 
                                 @ITA, @UK, @ES, @FRA
END
 
CLOSE crs
DEALLOCATE crs
                                   
GOTO ExitProc

/* Domini Gerarchici */

TipoDomG: 


DECLARE crs CURSOR STATIC FOR SELECT CASE WHEN dgCodiceInterno IS NOT NULL THEN '''' + dgCodiceInterno + '''' ELSE 'NULL' END
                                   , CASE WHEN dgCodiceEsterno IS NOT NULL THEN '''' + dgCodiceEsterno + '''' ELSE 'NULL' END
                                   , CASE WHEN dgPath IS NOT NULL THEN '''' + dgPath + '''' ELSE 'NULL' END
                                   , ISNULL(CAST(dgLivello AS VARCHAR(10)), 'NULL')
                                   , ISNULL(CAST(dgFoglia AS VARCHAR(10)), 'NULL')
                                   , ISNULL(CAST(dgLenPathPadre AS VARCHAR(10)), 'NULL')
                                   , CASE WHEN dgCodiceRaccordo IS NOT NULL THEN '''' + dgCodiceRaccordo + '''' ELSE 'NULL' END
                                   , CASE WHEN ITA.dscTesto IS NOT NULL THEN '''' + REPLACE(ITA.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                   , CASE WHEN UK.dscTesto IS NOT NULL THEN '''' + REPLACE(UK.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                   , CASE WHEN ES.dscTesto IS NOT NULL THEN '''' + REPLACE(ES.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                   , CASE WHEN FRA.dscTesto IS NOT NULL THEN '''' + REPLACE(FRA.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                FROM DominiGerarchici
                                   , DescsI ITA
                                   , DescsUK UK
                                   , DescsE ES
                                   , DescsFRA FRA
                               WHERE dgIdDsc = ITA.IdDsc
                                 AND dgIdDsc = UK.IdDsc
                                 AND dgIdDsc = ES.IdDsc
                                 AND dgIdDsc = FRA.IdDsc
                                 AND dgTipoGerarchia = @IdTid
                                 AND dgDeleted = 0
                              ORDER BY dgPath
 
OPEN crs
 
FETCH NEXT FROM crs INTO @dgCodiceInterno, @dgCodiceEsterno, @dgPath, @dgLivello, @dgFoglia, @dgLenPathPadre,
                         @dgCodiceRaccordo, @ITA, @UK, @ES, @FRA

WHILE @@FETCH_STATUS = 0
BEGIN
        PRINT ' '
        PRINT 'INSERT INTO DescsI (dscTesto)'
        PRINT '     VALUES (' + @ITA + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'SET @IdDsc = @@IDENTITY'
        PRINT ' '
        PRINT 'INSERT INTO DescsUK (IdDsc, dscTesto)'
        PRINT '     VALUES (@IdDsc, ' + @UK + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'INSERT INTO DescsE (IdDsc, dscTesto)'
        PRINT '     VALUES (@IdDsc, ' + @ES + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'INSERT INTO DescsFRA (IdDsc, dscTesto)'
        PRINT '     VALUES (@IdDsc, ' + @FRA + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'INSERT INTO DominiGerarchici (dgTipoGerarchia, dgCodiceInterno, dgCodiceEsterno, dgPath, dgLivello, dgFoglia, dgLenPathPadre, dgIdDsc, dgCodiceRaccordo)'
        PRINT '     VALUES (@IdTid, ' + @dgCodiceInterno + ', ' + @dgCodiceEsterno + ', ' + @dgPath + ', ' + @dgLivello + ', ' + @dgFoglia + ', ' + @dgLenPathPadre + ', @IdDsc, ' + @dgCodiceRaccordo + ')'
        PRINT ' '
        PRINT ' '
        PRINT 'SET @IdDg = @@IDENTITY'
        PRINT ' '
        
        IF @dgLivello = '1'
        BEGIN
                PRINT 'INSERT INTO MPDominiGerarchici (mpdgIdMp, mpdgIdDg, mpdgTipo)'
                PRINT '     VALUES (1, @IdDg, @IdTid)'
                PRINT ' '
                PRINT ' '
        END
        
        FETCH NEXT FROM crs INTO @dgCodiceInterno, @dgCodiceEsterno, @dgPath, @dgLivello, @dgFoglia, @dgLenPathPadre, 
                                 @dgCodiceRaccordo, @ITA, @UK, @ES, @FRA
END
 
CLOSE crs
DEALLOCATE crs


ExitProc:

PRINT ' '

IF @ommit_tran = 0
BEGIN
        PRINT 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT OFF'
END





GO
