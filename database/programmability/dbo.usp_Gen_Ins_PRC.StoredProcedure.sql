USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_PRC]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Gen_Ins_PRC] (
  @IdProcess VARCHAR(10)
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @Descr                                          VARCHAR(200)
DECLARE @prcIdMP                                        VARCHAR(10)
DECLARE @prcITypeSource                                 VARCHAR(10)
DECLARE @prcISubtypeSource                              VARCHAR(10)
DECLARE @prcIdProcess                                   VARCHAR(10)
DECLARE @prcITypeDest                                   VARCHAR(10)
DECLARE @prcISubtypeDest                                VARCHAR(10)
DECLARE @prcCondition                                   VARCHAR(200)
DECLARE @prcTypeCondition                               VARCHAR(200)
DECLARE @prcOrder                                       VARCHAR(10)
DECLARE @IdPa                                           VARCHAR(10)


DECLARE @RC                                             INT

IF NOT EXISTS (SELECT * FROM ProcessAnag WHERE IdProcess = @IdProcess)
BEGIN
        RAISERROR ('Processo [%s] non trovato in ProcessAnag', 16, 1, @IdProcess)
        RETURN 99
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdProcess                               INT'
        PRINT 'DECLARE @IdPa                                    INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

--

SELECT @Descr = CASE WHEN Descr IS NOT NULL THEN '''' + RTRIM(Descr) + '''' ELSE 'NULL' END
  FROM ProcessAnag
 WHERE IdProcess = @IdProcess
   
--

PRINT ' '
PRINT '/* Generazione Processo */'
PRINT ' '

IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET @IdProcess = ' + CAST(@IdProcess AS VARCHAR)
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT ProcessAnag ON'
        PRINT ' '
        PRINT 'INSERT INTO ProcessAnag (IdProcess, Descr)'
        PRINT '     VALUES (@IdProcess, ' + @Descr  + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" ProcessAnag'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT ProcessAnag OFF'
END
ELSE
BEGIN
        PRINT 'INSERT INTO ProcessAnag (Descr)'
        PRINT '     VALUES (' + @Descr  + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" ProcessAnag'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET @IdProcess = @@IDENTITY'
END


SELECT @prcIdMP = ISNULL(CAST(prcIdMP AS VARCHAR(10)), 'NULL')
     , @prcITypeSource = ISNULL(CAST(prcITypeSource AS VARCHAR(10)), 'NULL')
     , @prcISubtypeSource = ISNULL(CAST(prcISubtypeSource AS VARCHAR(10)), 'NULL')
     , @prcIdProcess = ISNULL(CAST(prcIdProcess AS VARCHAR(10)), 'NULL')
     , @prcITypeDest = ISNULL(CAST(prcITypeDest AS VARCHAR(10)), 'NULL')
     , @prcISubtypeDest = ISNULL(CAST(prcISubtypeDest AS VARCHAR(10)), 'NULL')
     , @prcCondition = CASE WHEN prcCondition IS NOT NULL THEN '''' + RTRIM(prcCondition) + '''' ELSE 'NULL' END
     , @prcTypeCondition = CASE WHEN prcTypeCondition IS NOT NULL THEN '''' + RTRIM(prcTypeCondition) + '''' ELSE 'NULL' END
     , @prcOrder = ISNULL(CAST(prcOrder AS VARCHAR(10)), 'NULL')
  FROM Process
 WHERE prcIdProcess = @IdProcess

PRINT ' '
PRINT 'INSERT INTO Process (prcIdMP, prcITypeSource, prcISubtypeSource, prcIdProcess, prcITypeDest, prcISubtypeDest, '
PRINT '                     prcCondition, prcTypeCondition, prcOrder)'
PRINT '     VALUES (' + @prcIdMP + ', ' + @prcITypeSource + ', ' + @prcISubtypeSource + ', @IdProcess, ' 
                      + @prcITypeDest + ', ' + @prcISubtypeDest + ', ' + @prcCondition + ', ' + @prcTypeCondition + ', ' + @prcOrder + ')'
PRINT ' '
PRINT 'IF @@ERROR <> 0'
PRINT 'BEGIN'
PRINT '        RAISERROR(''Errore "INSERT" Process'', 16, 1)'
PRINT '        ROLLBACK TRAN'
PRINT '        RETURN'
PRINT 'END'
PRINT ' '

PRINT ' '
PRINT '/* Fine Generazione Processo */'
PRINT ' '

DECLARE crsPA CURSOR STATIC FOR SELECT IdPA
                                  FROM ProcessActions
                                 WHERE IdProcess = @IdProcess
                                 ORDER BY paOrder
                               
OPEN crsPA

FETCH NEXT FROM crsPA INTO @IdPa

WHILE @@FETCH_STATUS = 0
BEGIN
        SET @RC = 0
        
        EXEC @RC = usp_gen_ins_pa @IdPa, 0, 1, 1, 1
        
        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_pa', 16, 1)
                CLOSE crsPA
                DEALLOCATE crsPA                
                RETURN 99
        END
        
        FETCH NEXT FROM crsPA INTO @IdPa
END

CLOSE crsPA
DEALLOCATE crsPA

IF @ommit_tran = 0
BEGIN
        PRINT 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT OFF'
END


GO
