USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_PRP]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Gen_Ins_PRP] (
  @IdAp VARCHAR(10)
, @ommit_pa BIT = 0
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @IdPA                                   VARCHAR(10)
DECLARE @prpAttrib                              VARCHAR(200)
DECLARE @prpValue                               VARCHAR(8000)

IF NOT EXISTS (SELECT * FROM ActionProp WHERE IdAp = @IdAp)
BEGIN
        RAISERROR ('Proprietà [%s] non trovata in ActionProp', 16, 1, @IdAp)
        RETURN 99
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdAp                            INT'
        PRINT 'DECLARE @IdPa                            INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

SELECT @IdPA = ISNULL(CAST(IdPA AS VARCHAR(10)), 'NULL')
     , @prpAttrib = CASE WHEN prpAttrib IS NOT NULL THEN '''' + prpAttrib + '''' ELSE 'NULL' END
     , @prpValue = CASE WHEN prpValue IS NOT NULL THEN '''' + REPLACE(prpValue, '''','''''') + '''' ELSE 'NULL' END
  FROM ActionProp
 WHERE IdAp = @IdAp
 
IF @ommit_pa = 0
        SET @IdPA = '@IdPa'

PRINT ' '
PRINT '/* Generazione Proprietà (ActionProp) */'
PRINT ' '


IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET @IdAp = ' + @IdAp
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT ActionProp ON'
        PRINT ' '
        PRINT 'INSERT INTO ActionProp (IdPA, prpAttrib, prpValue, IdAp)'
        PRINT '     VALUES (' + @IdPA  + ', ' + @prpAttrib + ', ' + @prpValue + ', @IdAp)'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" ActionProp'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT ActionProp OFF'
END
ELSE
BEGIN
        PRINT 'INSERT INTO ActionProp (IdPA, prpAttrib, prpValue)'
        PRINT '     VALUES (' + @IdPA  + ', ' + @prpAttrib + ', ' + @prpValue + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" ActionProp'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
END



PRINT ' '
PRINT '/* Fine Generazione Proprietà (ActionProp) */'
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
