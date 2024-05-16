USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_Mod]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Gen_Ins_Mod] (
  @IdMpMod VARCHAR(10)
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
, @var_suffix VARCHAR(20) = ''
)
AS
DECLARE @mpmIdMp                        VARCHAR(10)
DECLARE @mpmDesc                        VARCHAR(500)
DECLARE @mpmTipo                        VARCHAR(10)
DECLARE @mpmidmpmodvisual               VARCHAR(10)
DECLARE @mpmDeleted                     VARCHAR(10)

DECLARE @IdMdlAtt                       VARCHAR(10)
DECLARE @mpmaIdMpMod                    VARCHAR(10)
DECLARE @dztNome                        VARCHAR(50)
DECLARE @mpmaRegObblig                  VARCHAR(10)
DECLARE @mpmaOrdine                     VARCHAR(10)
DECLARE @mpmaValoreDef                  VARCHAR(1000)
DECLARE @mpmaPesoDef                    VARCHAR(10)
DECLARE @mpmaIdFva                      VARCHAR(10)
DECLARE @mpmaIdUmsDef                   VARCHAR(10)
DECLARE @mpmaDeleted                    VARCHAR(10)
DECLARE @mpmaDataUltimaMod              VARCHAR(20)
DECLARE @mpmaLocked                     VARCHAR(10)
DECLARE @mpmaShadow                     VARCHAR(10)
DECLARE @mpmaOpzioni                    VARCHAR(50)
DECLARE @mpmaOper                       VARCHAR(20)

DECLARE @mpacIdDzt                      VARCHAR(10)
DECLARE @mpacValue                      VARCHAR(8000)
DECLARE @mpacUltimaMod                  VARCHAR(20)
DECLARE @mpacDeleted                    VARCHAR(10)

DECLARE @docIdMp                        VARCHAR(10)
DECLARE @docItype                       VARCHAR(10)
DECLARE @docPath                        VARCHAR(100)
DECLARE @docIdMpMod                     VARCHAR(10)
DECLARE @docDeleted                     VARCHAR(10)
DECLARE @docDataUltimaMod               VARCHAR(20)
DECLARE @docISubType                    VARCHAR(10)
DECLARE @docIsReplicable                VARCHAR(10)

DECLARE @VarName                        VARCHAR(100)

IF NOT EXISTS (SELECT * FROM MPModelli WHERE IdMpMod = @IdMpMod)
BEGIN
        RAISERROR ('Modello [%s] non trovato', 16, 1, @IdMpMod)
        RETURN 99
END

SET @VarName = '@IdMpMod' + @var_suffix


PRINT ' '
PRINT '/* Generazione Modello */'
PRINT ' '

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE ' + @VarName + '                      INT'
        PRINT 'DECLARE @IdMdlAtt                     INT'
        PRINT ' '
END


IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

SELECT @mpmIdMp = ISNULL(CAST(mpmIdMp AS VARCHAR(10)), 'NULL')
     , @mpmDesc = CASE WHEN mpmDesc IS NOT NULL THEN '''' + RTRIM(mpmDesc) + '''' ELSE 'NULL' END
     , @mpmTipo = ISNULL(CAST(mpmTipo AS VARCHAR(10)), 'NULL')     
     , @mpmidmpmodvisual = ISNULL(CAST(mpmidmpmodvisual AS VARCHAR(10)), 'NULL') 
     , @mpmDeleted = ISNULL(CAST(mpmDeleted AS VARCHAR(10)), 'NULL')
  FROM MPModelli 
 WHERE IdMpMod = @IdMpMod

IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET ' + @VarName + ' = ' + @IdMpMod
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT MPModelli ON'
        PRINT ' '
        PRINT 'INSERT INTO MPModelli (IdMpMod, mpmIdMp, mpmDesc, mpmTipo, mpmidmpmodvisual, mpmDeleted)'
        PRINT '     VALUES (' + @VarName + ', ' + @mpmIdMp + ', ' + @mpmDesc + ', ' + @mpmTipo + ', ' 
                              + @mpmidmpmodvisual + ', ' + @mpmDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" MPModelli'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT MPModelli OFF'
        PRINT ' '
END
ELSE
BEGIN
        PRINT ' '
        PRINT 'INSERT INTO MPModelli (mpmIdMp, mpmDesc, mpmTipo, mpmidmpmodvisual, mpmDeleted)'
        PRINT '     VALUES (' + @mpmIdMp + ', ' + @mpmDesc + ', ' + @mpmTipo + ', ' + @mpmidmpmodvisual + ', ' 
                              + @mpmDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" MPModelli'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET ' + @VarName + ' = @@IDENTITY'
        PRINT ' '
END

/*
    MPDocumenti
*/

DECLARE crsDoc CURSOR STATIC FOR SELECT ISNULL(CAST(docIdMp AS VARCHAR(10)), 'NULL')
                                      , ISNULL(CAST(docItype AS VARCHAR(10)), 'NULL')
                                      , CASE WHEN docPath IS NOT NULL THEN '''' + docPath + '''' ELSE 'NULL' END
                                      , ISNULL(CAST(docIdMpMod AS VARCHAR(10)), 'NULL')
                                      , ISNULL(CAST(docDeleted AS VARCHAR(10)), 'NULL')
                                      , 'GETDATE()'
                                      , ISNULL(CAST(docISubType AS VARCHAR(10)), 'NULL')
                                      , ISNULL(CAST(docIsReplicable AS VARCHAR(10)), 'NULL')
                                   FROM MPDocumenti
                                  WHERE docIdMpMod = @IdMpMod
                                    AND docDeleted = 0

OPEN crsDoc

FETCH NEXT FROM crsDoc INTO @docIdMp, @docItype, @docPath, @docIdMpMod, @docDeleted, @docDataUltimaMod, @docISubType, @docIsReplicable

WHILE @@FETCH_STATUS = 0
BEGIN
        PRINT 'INSERT INTO MPDocumenti (docIdMp, docItype, docPath, docIdMpMod, docDeleted, docDataUltimaMod, docISubType, docIsReplicable)'
        PRINT '     VALUES (' + @docIdMp + ', ' + @docItype + ', ' + @docPath + ', ' + @VarName + ', ' + @docDeleted 
                              + ', ' + @docDataUltimaMod + ', ' + @docISubType + ', ' + @docIsReplicable + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" MPModelliAttributi'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '

        FETCH NEXT FROM crsDoc INTO @docIdMp, @docItype, @docPath, @docIdMpMod, @docDeleted, @docDataUltimaMod, 
                                    @docISubType, @docIsReplicable
END

CLOSE crsDoc
DEALLOCATE crsDoc

/*
    MPModelliAttributi
*/

DECLARE crsMPMA CURSOR STATIC FOR SELECT ISNULL(CAST(IdMdlAtt AS VARCHAR(10)), 'NULL')
                                   , ISNULL(CAST(mpmaIdMpMod AS VARCHAR(10)), 'NULL')
                                   , CASE WHEN dztNome IS NOT NULL THEN '''' + dztNome + '''' ELSE 'NULL' END
                                   , ISNULL(CAST(mpmaRegObblig AS VARCHAR(10)), 'NULL')
                                   , ISNULL(CAST(mpmaOrdine AS VARCHAR(10)), 'NULL')
                                   , CASE WHEN mpmaValoreDef IS NOT NULL THEN '''' + mpmaValoreDef + '''' ELSE 'NULL' END
                                   , ISNULL(CAST(mpmaDeleted AS VARCHAR(10)), 'NULL')
                                   , 'GETDATE()'
                                   , ISNULL(CAST(mpmaLocked AS VARCHAR(10)), 'NULL')
                                   , ISNULL(CAST(mpmaShadow AS VARCHAR(10)), 'NULL')
                                   , CASE WHEN mpmaOpzioni IS NOT NULL THEN '''' + mpmaOpzioni + '''' ELSE 'NULL' END
                                   , CASE WHEN mpmaOper IS NOT NULL THEN '''' + mpmaOper + '''' ELSE 'NULL' END
                                FROM MPModelliAttributi
                                   , DizionarioAttributi
                               WHERE mpmaIdDzt = IdDzt
                                 AND mpmaIdMpMod = @IdMpMod
                                 AND mpmaDeleted = 0

OPEN crsMPMA

FETCH NEXT FROM crsMPMA INTO @IdMdlAtt, @mpmaIdMpMod, @dztNome, @mpmaRegObblig, @mpmaOrdine, @mpmaValoreDef, @mpmaDeleted, 
                         @mpmaDataUltimaMod, @mpmaLocked, @mpmaShadow, @mpmaOpzioni, @mpmaOper

WHILE @@FETCH_STATUS = 0
BEGIN
        PRINT 'IF NOT EXISTS (SELECT * FROM DizionarioAttributi WHERE dztNome = ' + @dztNome + ')'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Attributo "' + REPLACE(@dztNome, '''', '') + '" non trovato'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'INSERT INTO MPModelliAttributi (mpmaIdMpMod, mpmaIdDzt, mpmaRegObblig, mpmaOrdine, mpmaValoreDef, mpmaDeleted, mpmaDataUltimaMod, mpmaLocked, mpmaShadow, mpmaOpzioni, mpmaOper)'
        PRINT 'SELECT ' + @VarName + ', IdDzt, ' + @mpmaRegObblig + ', ' + @mpmaOrdine + ', ' + @mpmaValoreDef + ', ' + @mpmaDeleted 
                                          + ', ' + @mpmaDataUltimaMod + ', ' + @mpmaLocked + ', ' + @mpmaShadow 
                                          + ', ' + @mpmaOpzioni + ', ' + @mpmaOper
        PRINT '  FROM DizionarioAttributi'
        PRINT ' WHERE dztNome = ' + @dztNome
        
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" MPModelliAttributi'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET @IdMdlAtt = @@IDENTITY'
        PRINT ' '
        
        DECLARE crsMPAC CURSOR STATIC FOR SELECT ISNULL(CAST(mpacIdDzt AS VARCHAR(10)), 'NULL')
                                            , CASE WHEN mpacValue IS NOT NULL THEN '''' + mpacValue + '''' ELSE 'NULL' END
                                            , 'GETDATE()'
                                            , ISNULL(CAST(mpacDeleted AS VARCHAR(10)), 'NULL')
                                         FROM MPAttributiControlli
                                        WHERE mpacIdMdlAtt = @IdMdlAtt
                                          AND mpacDeleted = 0
                                          
        OPEN crsMPAC
        
        FETCH NEXT FROM crsMPAC INTO @mpacIdDzt, @mpacValue, @mpacUltimaMod, @mpacDeleted
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
                PRINT 'INSERT INTO MPAttributiControlli (mpacIdMdlAtt, mpacIdDzt, mpacValue, mpacUltimaMod, mpacDeleted)'
                PRINT '     VALUES (@IdMdlAtt, ' + @mpacIdDzt + ', ' + @mpacValue + ', ' + @mpacUltimaMod + ', ' + @mpacDeleted + ')'
                PRINT ' '
                PRINT 'IF @@ERROR <> 0'
                PRINT 'BEGIN'
                PRINT '        RAISERROR(''Errore "INSERT" MPAttributiControlli'', 16, 1)'
                PRINT '        ROLLBACK TRAN'
                PRINT '        RETURN'
                PRINT 'END'
                PRINT ' '
        
        
                FETCH NEXT FROM crsMPAC INTO @mpacIdDzt, @mpacValue, @mpacUltimaMod, @mpacDeleted
        END
        
        CLOSE crsMPAC
        DEALLOCATE crsMPAC                                          
        
        FETCH NEXT FROM crsMPMA INTO @IdMdlAtt, @mpmaIdMpMod, @dztNome, @mpmaRegObblig, @mpmaOrdine, @mpmaValoreDef, @mpmaDeleted, 
                                 @mpmaDataUltimaMod, @mpmaLocked, @mpmaShadow, @mpmaOpzioni, @mpmaOper
END

CLOSE crsMPMA
DEALLOCATE crsMPMA

PRINT ' '
PRINT '/* Fine Generazione Modello */'
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
