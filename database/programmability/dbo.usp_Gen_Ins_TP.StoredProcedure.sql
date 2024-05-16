USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_TP]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Gen_Ins_TP] (
  @IdTp VARCHAR(10)
, @ommit_ct BIT = 0
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @tpIdCt                                         VARCHAR(10)
DECLARE @tpItypeSource                                  VARCHAR(10)
DECLARE @tpISubTypeSource                               VARCHAR(10)
DECLARE @tpAttrib                                       VARCHAR(100)
DECLARE @tpValue                                        VARCHAR(500)
DECLARE @tpUltimaMod                                    VARCHAR(10)
DECLARE @tpDeleted                                      VARCHAR(10)

IF NOT EXISTS (SELECT * FROM TabProps WHERE IdTp = @IdTp AND tpDeleted = 0)
BEGIN
        RAISERROR ('Proprietà [%s] non trovata in TabProps', 16, 1, @IdTp)
        RETURN 99
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdCt                            INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END



SELECT @tpIdCt = ISNULL(CAST(tpIdCt AS VARCHAR(10)), 'NULL')
     , @tpItypeSource = ISNULL(CAST(tpItypeSource AS VARCHAR(10)), 'NULL')
     , @tpISubTypeSource = ISNULL(CAST(tpISubTypeSource AS VARCHAR(10)), 'NULL')
     , @tpAttrib = CASE WHEN tpAttrib IS NOT NULL THEN '''' + tpAttrib + '''' ELSE 'NULL' END
     , @tpValue = CASE WHEN tpValue IS NOT NULL THEN '''' + tpValue + '''' ELSE 'NULL' END
     , @tpUltimaMod = 'GETDATE()'
     , @tpDeleted = ISNULL(CAST(tpDeleted AS VARCHAR(10)), 'NULL')
  FROM TabProps
 WHERE IdTp = @IdTp
   AND tpDeleted = 0
  
IF @ommit_ct = 0
        SET @tpIdCt = '@IdCt'

PRINT ' '
PRINT '/* Generazione Proprietà (TabProps) */'
PRINT ' '


IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT TabProps ON'
        PRINT ' '
        PRINT 'INSERT INTO TabProps (IdTp, tpIdCt, tpItypeSource, tpISubTypeSource, tpAttrib, tpValue, tpUltimaMod, tpDeleted)'
        PRINT '     VALUES (' + @IdTp  + ', ' + @tpIdCt + ', ' + @tpItypeSource + ', ' + @tpISubTypeSource + ', '  + @tpAttrib + ', '
                              + @tpValue + ', ' + @tpUltimaMod + ', ' + @tpDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" TabProps'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT TabProps OFF'
END
ELSE
BEGIN
        PRINT 'INSERT INTO TabProps (tpIdCt, tpItypeSource, tpISubTypeSource, tpAttrib, tpValue, tpUltimaMod, tpDeleted)'
        PRINT '     VALUES (@IdCt, ' + @tpItypeSource + ', ' + @tpISubTypeSource + ', '  + @tpAttrib + ', '
                              + @tpValue + ', ' + @tpUltimaMod + ', ' + @tpDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" TabProps'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
END


PRINT ' '
PRINT '/* Fine Generazione Proprietà (TabProps) */'
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
