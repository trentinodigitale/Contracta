USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_Mlng]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_Gen_Ins_Mlng] (
  @IdMultilng VARCHAR(400)
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)

AS

DECLARE @mlngDesc_I                     VARCHAR(8000)
DECLARE @mlngDesc_UK                    VARCHAR(8000)
DECLARE @mlngDesc_E                     VARCHAR(8000)
DECLARE @mlngDesc_FRA                   VARCHAR(8000)

SET @IdMultilng = RTRIM(@IdMultilng)

IF NOT EXISTS (SELECT * FROM Multilinguismo WHERE IdMultilng = @IdMultilng AND mlngCancellato = 0)
BEGIN
        RAISERROR ('Chiave [%s] non trovata', 16, 1, @IdMultilng)
        RETURN 99
END

SELECT @mlngDesc_I   = CASE WHEN CAST(mlngDesc_I   AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(mlngDesc_I  AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
     , @mlngDesc_UK  = CASE WHEN CAST(mlngDesc_UK  AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(mlngDesc_UK  AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
     , @mlngDesc_E   = CASE WHEN CAST(mlngDesc_E   AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(mlngDesc_E   AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
     , @mlngDesc_FRA = CASE WHEN CAST(mlngDesc_FRA AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(mlngDesc_FRA AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
  FROM Multilinguismo
 WHERE IdMultilng = @IdMultilng
 
IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

PRINT ' '
PRINT 'IF NOT EXISTS (SELECT * FROM Multilinguismo WHERE IdMultilng = ''' + @IdMultilng + ''')'
PRINT 'BEGIN'
PRINT '         INSERT INTO Multilinguismo (IdMultilng, mlngDesc_I, mlngDesc_UK, mlngDesc_E, mlngDesc_FRA)'
PRINT '                 VALUES (''' + @IdMultilng + ''', ' + @mlngDesc_I + ', ' + @mlngDesc_UK + ', ' + @mlngDesc_E + ', ' + @mlngDesc_FRA+ ')'
PRINT ' '
PRINT '         IF @@ERROR <> 0'
PRINT '         BEGIN'
PRINT '                 RAISERROR(''Errore "INSERT" Multilinguismo'', 16, 1)'
PRINT '                 ROLLBACK TRAN'
PRINT '                 RETURN'
PRINT '         END'
PRINT ' '
PRINT 'END'
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
