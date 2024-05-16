USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_CT]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[usp_Gen_Ins_CT] (
  @IdCT VARCHAR(10)
, @ommit_fnc BIT = 0
, @ommit_mod BIT = 0
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @IdCA                                           VARCHAR(10)
DECLARE @IdTP                                           VARCHAR(10)
DECLARE @ctIdMp                                         VARCHAR(10)
DECLARE @ctItype                                        VARCHAR(10)
DECLARE @ctIsubtype                                     VARCHAR(10)
DECLARE @ctIdMultiLng                                   VARCHAR(200)
DECLARE @ctProfile                                      VARCHAR(20)
DECLARE @ctFnzuPos                                      VARCHAR(10)
DECLARE @ctOrder                                        VARCHAR(10)
DECLARE @ctDeleted                                      VARCHAR(10)
DECLARE @ctPath                                         VARCHAR(1000)
DECLARE @ctUltimaMod                                    VARCHAR(10)
DECLARE @ctParent                                       VARCHAR(10)
DECLARE @ctTabType                                      VARCHAR(100)
DECLARE @ctIdGrp                                        VARCHAR(10)
DECLARE @ctTabName                                      VARCHAR(100)
DECLARE @ctProgId                                       VARCHAR(100)

DECLARE @ommit_mod_tmp                                  BIT

DECLARE @RC                                             INT

IF NOT EXISTS (SELECT * FROM CompanyTab WHERE IdCT = @IdCT AND ctDeleted = 0)
BEGIN
        RAISERROR ('Sezione [%s] non trovata in CompanyTab', 16, 1, @IdCT)
        RETURN 99
END

SET @ommit_mod_tmp = @ommit_mod

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdCT                                    INT'
        PRINT 'DECLARE @IdMpMod                                 INT'
        PRINT 'DECLARE @IdMpMod_fnc_1                           INT'
        PRINT 'DECLARE @IdMpMod_fnc_2                           INT'
        PRINT 'DECLARE @IdMpMod_fnc_3                           INT'
        PRINT 'DECLARE @fncParamNew                             VARCHAR(8000)'
        PRINT 'DECLARE @IdMdlAtt                                INT'
        PRINT 'DECLARE @IdGrp                                   INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

SELECT @ctIdMp = ISNULL(CAST(ctIdMp AS VARCHAR(10)), 'NULL')
     , @ctItype = ISNULL(CAST(ctItype AS VARCHAR(10)), 'NULL')
     , @ctIsubtype = ISNULL(CAST(ctIsubtype AS VARCHAR(10)), 'NULL')
     , @ctIdMultiLng = CASE WHEN ctIdMultiLng IS NOT NULL THEN '''' + RTRIM(ctIdMultiLng) + '''' ELSE 'NULL' END
     , @ctProfile = CASE WHEN ctProfile IS NOT NULL THEN '''' + ctProfile + '''' ELSE 'NULL' END
     , @ctFnzuPos = ISNULL(CAST(ctFnzuPos AS VARCHAR(10)), 'NULL')
     , @ctOrder = ISNULL(CAST(ctOrder AS VARCHAR(10)), 'NULL')
     , @ctDeleted = ISNULL(CAST(ctDeleted AS VARCHAR(10)), 'NULL')
     , @ctPath = CASE WHEN ctPath IS NOT NULL THEN '''' + ctPath + '''' ELSE 'NULL' END
     , @ctUltimaMod = 'GETDATE()'
     , @ctParent = ISNULL(CAST(ctParent AS VARCHAR(10)), 'NULL')
     , @ctTabType = CASE WHEN ctTabType IS NOT NULL THEN '''' + ctTabType + '''' ELSE 'NULL' END
     , @ctIdGrp = ISNULL(CAST(ctIdGrp AS VARCHAR(10)), 'NULL')
     , @ctTabName = CASE WHEN ctTabName IS NOT NULL THEN '''' + ctTabName + '''' ELSE 'NULL' END
     , @ctProgId = CASE WHEN ctProgId IS NOT NULL THEN '''' + ctProgId + '''' ELSE 'NULL' END
  FROM CompanyTab
 WHERE IdCt = @IdCt
   AND ctDeleted = 0
   
--

IF @ommit_fnc = 0 AND @ctIdGrp <> 'NULL'
BEGIN
        SET @RC = 0
        
        EXEC @RC = usp_gen_ins_fnc @ctIdGrp, @ommit_tran = 1, @ommit_declare = 1, @ommit_mod = @ommit_mod_tmp
        
        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_fnc', 16, 1)
                RETURN 99
        END
        
        SET @ctIdGrp = '@IdGrp'
END

PRINT ' '
PRINT '/* Generazione Sezione */'
PRINT ' '


IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET @IdCT = ' + CAST(@IdCt AS VARCHAR)
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT CompanyTab ON'
        PRINT ' '
        PRINT 'INSERT INTO CompanyTab (IdCt, ctIdMp, ctItype, ctIsubtype, ctIdMultiLng, ctProfile, ctFnzuPos, ctOrder, ctDeleted, ctPath, ctUltimaMod, ctParent, ctTabType, ctIdGrp, ctTabName, ctProgId)'
        PRINT '     VALUES (@IdCt, ' + @ctIdMp + ', ' + @ctItype + ', ' + @ctIsubtype + ', '  + @ctIdMultiLng + ', '
                              + @ctProfile + ', ' + @ctFnzuPos + ', ' + @ctOrder + ', ' + @ctDeleted + ', ' 
                              + @ctPath + ', ' + @ctUltimaMod + ', ' + @ctParent + ', ' + @ctTabType + ', ' 
                              + @ctIdGrp + ', ' + @ctTabName + ', ' + @ctProgId + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" CompanyTab'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT CompanyTab OFF'
END
ELSE
BEGIN
        PRINT 'INSERT INTO CompanyTab (ctIdMp, ctItype, ctIsubtype, ctIdMultiLng, ctProfile, ctFnzuPos, ctOrder, ctDeleted, ctPath, ctUltimaMod, ctParent, ctTabType, ctIdGrp, ctTabName, ctProgId)'
        PRINT '     VALUES (' + @ctIdMp + ', ' + @ctItype + ', ' + @ctIsubtype + ', '  + @ctIdMultiLng + ', '
                              + @ctProfile + ', ' + @ctFnzuPos + ', ' + @ctOrder + ', ' + @ctDeleted + ', ' 
                              + @ctPath + ', ' + @ctUltimaMod + ', ' + @ctParent + ', ' + @ctTabType + ', ' 
                              + @ctIdGrp + ', ' + @ctTabName + ', ' + @ctProgId + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" CompanyTab'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET @IdCt = @@IDENTITY'
END


PRINT ' '
PRINT '/* Fine Generazione Sezione */'
PRINT ' '

DECLARE crsCA CURSOR STATIC FOR SELECT IdCa
                                  FROM CompanyArea
                                 WHERE caIdCt = @IdCt
                                   AND caDeleted = 0
                                 ORDER BY caOrder
                               
OPEN crsCA

FETCH NEXT FROM crsCA INTO @Idca

WHILE @@FETCH_STATUS = 0
BEGIN
        SET @RC = 0
        
        EXEC @RC = usp_gen_ins_ca @IdCa, 0, @ommit_fnc, @ommit_mod, 1, 1, 1
        
        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_ca', 16, 1)
                CLOSE crsCA
                DEALLOCATE crsCA                
                RETURN 99
        END
        
        FETCH NEXT FROM crsCA INTO @Idca
END

CLOSE crsCA
DEALLOCATE crsCA

DECLARE crsTP CURSOR STATIC FOR SELECT IdTp
                                  FROM TabProps
                                 WHERE tpIdCt = @IdCt
                                   AND tpDeleted = 0
                                 ORDER BY 1
                                 
OPEN crsTP

FETCH NEXT FROM crsTP INTO @IdTp

WHILE @@FETCH_STATUS = 0
BEGIN
        SET @RC = 0
        
        EXEC @RC = usp_gen_ins_tp @IdTp, 0, 1, 1, 1
        
        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_tp', 16, 1)
                CLOSE crsTP
                DEALLOCATE crsTP                
                RETURN 99
        END
        
        FETCH NEXT FROM crsTP INTO @IdTp
END
CLOSE crsTP
DEALLOCATE crsTP

IF @ommit_tran = 0
BEGIN
        PRINT 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT OFF'
END







GO
