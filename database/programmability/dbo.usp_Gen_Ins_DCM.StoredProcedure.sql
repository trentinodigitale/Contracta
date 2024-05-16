USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_DCM]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Gen_Ins_DCM] (
  @IdDcm VARCHAR(10)
, @ommit_fnc BIT = 0
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @dcmDescription                                 VARCHAR(200)
DECLARE @dcmIType                                       VARCHAR(10)
DECLARE @dcmIsubType                                    VARCHAR(10)
DECLARE @dcmRelatedIdDcm                                VARCHAR(10)
DECLARE @dcmInput                                       VARCHAR(10)
DECLARE @dcmDeleted                                     VARCHAR(10)
DECLARE @dcmUltimaMod                                   VARCHAR(10)
DECLARE @dcmTypeDoc                                     VARCHAR(20)
DECLARE @dcmStorico                                     VARCHAR(10)
DECLARE @dcmDetail                                      VARCHAR(10)
DECLARE @dcmSendUnreadAdvise                            VARCHAR(10)
DECLARE @dcmOption                                      VARCHAR(200)
DECLARE @dcmIdGrp                                       VARCHAR(10)
DECLARE @dcmURL                                         VARCHAR(2000)
DECLARE @dcmISubTypeRef                                 VARCHAR(10)

DECLARE @RC                                             INT

IF NOT EXISTS (SELECT * FROM Document WHERE IdDcm = @IdDcm AND dcmDeleted = 0)
BEGIN
        RAISERROR ('Documento [%s] non trovato in Document', 16, 1, @IdDcm)
        RETURN 99
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdGrp                           INT'
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

SELECT @dcmDescription = CASE WHEN dcmDescription IS NOT NULL THEN '''' + RTRIM(dcmDescription) + '''' ELSE 'NULL' END
     , @dcmIType = ISNULL(CAST(dcmIType AS VARCHAR(10)), 'NULL')
     , @dcmIsubType = ISNULL(CAST(dcmIsubType AS VARCHAR(10)), 'NULL')
     , @dcmRelatedIdDcm = 'NULL'
     , @dcmInput = ISNULL(CAST(dcmInput AS VARCHAR(10)), 'NULL')
     , @dcmDeleted = ISNULL(CAST(dcmDeleted AS VARCHAR(10)), 'NULL')
     , @dcmUltimaMod = 'GETDATE()'
     , @dcmTypeDoc = ISNULL(CAST(dcmTypeDoc AS VARCHAR(10)), 'NULL')
     , @dcmStorico = ISNULL(CAST(dcmStorico AS VARCHAR(10)), 'NULL')
     , @dcmDetail = CASE WHEN dcmDetail IS NOT NULL THEN '''' + RTRIM(dcmDetail) + '''' ELSE 'NULL' END
     , @dcmSendUnreadAdvise = ISNULL(CAST(dcmSendUnreadAdvise AS VARCHAR(10)), 'NULL')
     , @dcmOption = CASE WHEN dcmOption IS NOT NULL THEN '''' + RTRIM(dcmOption) + '''' ELSE 'NULL' END
     , @dcmIdGrp = ISNULL(CAST(dcmIdGrp AS VARCHAR(10)), 'NULL')
     , @dcmURL = CASE WHEN dcmURL IS NOT NULL THEN '''' + RTRIM(dcmURL) + '''' ELSE 'NULL' END
     , @dcmISubTypeRef = ISNULL(CAST(dcmISubTypeRef AS VARCHAR(10)), 'NULL')
  FROM Document
 WHERE IdDcm = @IdDcm
   AND dcmDeleted = 0    

IF @ommit_fnc = 0 AND @dcmIdGrp <> 'NULL'
BEGIN
        SET @RC = 0

        EXEC @RC = usp_gen_ins_fnc @dcmIdGrp, @ommit_tran = 1, @ommit_declare = 1, @ommit_mod = 1

        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_fnc', 16, 1)
                RETURN 99
        END

        SET @dcmIdGrp = '@IdGrp'
END

PRINT ' '
PRINT '/* Generazione Documento (Document) */'
PRINT ' '

IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT Document ON'
        PRINT ' '
        PRINT 'INSERT INTO Document (IdDcm, dcmDescription, dcmIType, dcmIsubType, dcmRelatedIdDcm, dcmInput, dcmDeleted, dcmUltimaMod, dcmTypeDoc, dcmStorico, dcmDetail, dcmSendUnreadAdvise, dcmOption, dcmIdGrp, dcmURL, dcmISubTypeRef)'
        PRINT '     VALUES (' + @IdDcm  + ',' + @dcmDescription + ', ' + @dcmIType + ', ' + @dcmIsubType + ', '  + @dcmRelatedIdDcm + ', '  
                              + @dcmInput + ', '  + @dcmDeleted + ', '  + @dcmUltimaMod + ', '  + @dcmTypeDoc + ', '  
                              + @dcmStorico + ', '  + @dcmDetail + ', '  + @dcmSendUnreadAdvise + ', '  + @dcmOption + ', '  
                              + @dcmIdGrp + ', '  + @dcmURL + ', ' + @dcmISubTypeRef + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" Document'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT Document OFF'
END
ELSE
BEGIN
        PRINT 'INSERT INTO Document (dcmDescription, dcmIType, dcmIsubType, dcmRelatedIdDcm, dcmInput, dcmDeleted, dcmUltimaMod, dcmTypeDoc, dcmStorico, dcmDetail, dcmSendUnreadAdvise, dcmOption, dcmIdGrp, dcmURL, dcmISubTypeRef)'
        PRINT '     VALUES (' + @dcmDescription + ', ' + @dcmIType + ', ' + @dcmIsubType + ', '  + @dcmRelatedIdDcm + ', '  
                              + @dcmInput + ', '  + @dcmDeleted + ', '  + @dcmUltimaMod + ', '  + @dcmTypeDoc + ', '  
                              + @dcmStorico + ', '  + @dcmDetail + ', '  + @dcmSendUnreadAdvise + ', '  + @dcmOption + ', '  
                              + @dcmIdGrp + ', '  + @dcmURL + ', ' + @dcmISubTypeRef + ')'
PRINT ' '
PRINT 'IF @@ERROR <> 0'
PRINT 'BEGIN'
PRINT '        RAISERROR(''Errore "INSERT" Document'', 16, 1)'
PRINT '        ROLLBACK TRAN'
PRINT '        RETURN'
PRINT 'END'
END


PRINT ' '
PRINT '/* Fine Generazione Documento (Document) */'
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
