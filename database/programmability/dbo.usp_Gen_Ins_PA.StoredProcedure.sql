USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_PA]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Gen_Ins_PA] (
  @IdPA VARCHAR(10)
, @ommit_prc BIT = 0
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @IdPANew                                        INT
DECLARE @IdProcess                                      VARCHAR(10)
DECLARE @IdAct                                          VARCHAR(10)
DECLARE @paOrder                                        VARCHAR(10)
DECLARE @IdAp                                           VARCHAR(10)

DECLARE @RC                                             INT

IF NOT EXISTS (SELECT * FROM ProcessActions WHERE IdPA = @IdPA)
BEGIN
        RAISERROR ('Record [%s] non trovato in ProcessActions', 16, 1, @IdPA)
        RETURN 99
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdPA                                    INT'
        PRINT 'DECLARE @IdProcess                               INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

SELECT @IdProcess = ISNULL(CAST(IdProcess AS VARCHAR(10)), 'NULL')
     , @IdAct = ISNULL(CAST(IdAct AS VARCHAR(10)), 'NULL')
     , @paOrder = ISNULL(CAST(paOrder AS VARCHAR(10)), 'NULL')
  FROM ProcessActions
 WHERE IdPa = @IdPa


IF @ommit_prc = 0
BEGIN
        SET @IdProcess = '@IdProcess'
END

PRINT ' '
PRINT '/* Generazione Record ProcessActions */'
PRINT ' '

IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET @IdPA = ' + @IdPA
        PRINT ' '
        PRINT 'INSERT INTO ProcessActions (IdPA, IdProcess, IdAct, paOrder)'
        PRINT '     VALUES (@IdPa, ' + @IdProcess + ', ' + RTRIM(@IdAct) + ', ' + @paOrder + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" ProcessActions'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
END
ELSE
BEGIN
        PRINT ' '
        PRINT 'SELECT @IdPA = MAX(IdPA)'
        PRINT '  FROM ProcessActions'
        PRINT ' '
        PRINT 'SET @IdPA = @IdPA + 1'
        PRINT ' '
        PRINT 'INSERT INTO ProcessActions (IdPA, IdProcess, IdAct, paOrder)'
        PRINT '     VALUES (@IdPa, ' + @IdProcess + ', ' + RTRIM(@IdAct) + ', ' + @paOrder + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" ProcessActions'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
END


PRINT ' '
PRINT '/* Fine Generazione Record ProcessActions */'
PRINT ' '

DECLARE crsPRP CURSOR STATIC FOR SELECT IdAp
                                  FROM ActionProp
                                 WHERE IdPA = @IdPA
                                 ORDER BY IdAp
                               
OPEN crsPRP

FETCH NEXT FROM crsPRP INTO @IdAp

WHILE @@FETCH_STATUS = 0
BEGIN
        SET @RC = 0
        
        EXEC @RC = usp_gen_ins_prp @IdAp, 0, 1, 1, 1
        
        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_prp', 16, 1)
                CLOSE crsPRP
                DEALLOCATE crsPRP                
                RETURN 99
        END
        
        FETCH NEXT FROM crsPRP INTO @IdAp
END

CLOSE crsPRP
DEALLOCATE crsPRP


IF @ommit_tran = 0
BEGIN
        PRINT 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT OFF'
END





GO
