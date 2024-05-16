USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_CA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Gen_Ins_CA] (
  @IdCa VARCHAR(10)
, @ommit_ct BIT = 0
, @ommit_fnc BIT = 0
, @ommit_mod BIT = 0
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @caIdCt                                         VARCHAR(10)
DECLARE @caType                                         VARCHAR(100)
DECLARE @caIdMpMod                                      VARCHAR(10)
DECLARE @caOrder                                        VARCHAR(10)
DECLARE @caIdMultiLng                                   VARCHAR(200)                                                       
DECLARE @caRange                                        VARCHAR(100)
DECLARE @caDeleted                                      VARCHAR(10)
DECLARE @caUltimaMod                                    VARCHAR(20)
DECLARE @caIdGrp                                        VARCHAR(10)
DECLARE @caAreaName                                     VARCHAR(200)

DECLARE @ommit_mod_tmp                                  BIT

DECLARE @RC                                             INT


IF NOT EXISTS (SELECT * FROM CompanyArea WHERE IdCA = @IdCA AND caDeleted = 0)
BEGIN
        RAISERROR ('Area [%s] non trovata in CompanyArea', 16, 1, @IdCA)
        RETURN 99
END

SET @ommit_mod_tmp = @ommit_mod

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdMpMod                         INT'
        PRINT 'DECLARE @IdMdlAtt                        INT'
        PRINT 'DECLARE @IdGrp                           INT'
        PRINT 'DECLARE @IdCt                            INT'
        PRINT 'DECLARE @IdMpMod_fnc_1                           INT'
        PRINT 'DECLARE @IdMpMod_fnc_2                           INT'
        PRINT 'DECLARE @IdMpMod_fnc_3                           INT'
        PRINT 'DECLARE @fncParamNew                             VARCHAR(8000)'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

SELECT @caIdCt = ISNULL(CAST(caIdCt AS VARCHAR(10)), 'NULL')
     , @caType = CASE WHEN caType IS NOT NULL THEN '''' + caType + '''' ELSE 'NULL' END
     , @caIdMpMod = ISNULL(CAST(caIdMpMod AS VARCHAR(10)), 'NULL')
     , @caOrder = ISNULL(CAST(caOrder AS VARCHAR(10)), 'NULL')
     , @caIdMultiLng = CASE WHEN caIdMultiLng IS NOT NULL THEN '''' + RTRIM(caIdMultiLng) + '''' ELSE 'NULL' END
     , @caRange = CASE WHEN caRange IS NOT NULL THEN '''' + caRange + '''' ELSE 'NULL' END
     , @caDeleted = ISNULL(CAST(caDeleted AS VARCHAR(10)), 'NULL')
     , @caUltimaMod = 'GETDATE()'
     , @caIdGrp = ISNULL(CAST(caIdGrp AS VARCHAR(10)), 'NULL')
     , @caAreaName = CASE WHEN caAreaName IS NOT NULL THEN '''' + caAreaName + '''' ELSE 'NULL' END
  FROM CompanyArea
 WHERE IdCa = @IdCa
   AND caDeleted = 0
   
IF @ommit_ct = 0
        SET @caIdCt = '@IdCt'

IF @ommit_mod = 0 AND @caIdMpMod <> 'NULL' AND @caIdMpMod <> '-1'
BEGIN
        SET @RC = 0

        EXEC @RC = usp_gen_ins_mod @caIdMpMod, @ommit_tran = 1, @ommit_declare = 1
        
        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_mod', 16, 1)
                RETURN 99
        END
        
        SET @caIdMpMod = '@IdMpMod'
END
   
IF @ommit_fnc = 0 AND @caIdGrp <> 'NULL'
BEGIN
        SET @RC = 0

        EXEC @RC = usp_gen_ins_fnc @caIdGrp, @ommit_tran = 1, @ommit_declare = 1, @ommit_mod = @ommit_mod_tmp

        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_fnc, %d', 16, 1, @caIdGrp)
                RETURN 99
        END

        SET @caIdGrp = '@IdGrp'
END

PRINT ' '
PRINT '/* Generazione Area */'
PRINT ' '


IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT CompanyArea ON'
        PRINT ' '
        PRINT 'INSERT INTO CompanyArea (IdCa, caIdCt, caType, caIdMpMod, caOrder, caIdMultiLng, caRange, caDeleted, caUltimaMod, caIdGrp, caAreaName)'
        PRINT '     VALUES (' + @IdCa  + ', ' + @caIdCt + ', ' + @caType + ', ' + @caIdMpMod + ', '  + @caOrder + ', '
                              + @caIdMultiLng + ', ' + @caRange + ', ' + @caDeleted + ', ' + @caUltimaMod + ', ' 
                              + @caIdGrp + ', ' + @caAreaName + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" CompanyArea'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT CompanyArea OFF'
        PRINT ' '

END
ELSE
BEGIN
        PRINT 'INSERT INTO CompanyArea (caIdCt, caType, caIdMpMod, caOrder, caIdMultiLng, caRange, caDeleted, caUltimaMod, caIdGrp, caAreaName)'
        PRINT '     VALUES (' + @caIdCt + ', ' + @caType + ', ' + @caIdMpMod + ', '  + @caOrder + ', '
                              + @caIdMultiLng + ', ' + @caRange + ', ' + @caDeleted + ', ' + @caUltimaMod + ', ' 
                              + @caIdGrp + ', ' + @caAreaName + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" CompanyArea'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
END

PRINT ' '
PRINT '/* Fine Generazione Area */'
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
