USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_Mlng_SEL]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Gen_Ins_Mlng_SEL] (
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
DECLARE @sqlCMD                         VARCHAR(8000)

SET @IdMultilng = RTRIM(@IdMultilng)
SET @sqlCMD = ''

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
        SET  @sqlCMD = @sqlCMD + 'SET NOCOUNT ON' + CHAR(13)
END

IF @ommit_tran = 0
BEGIN
        SET  @sqlCMD = @sqlCMD + 'BEGIN TRAN' + CHAR(13)
END

SET @sqlCMD =  @sqlCMD + CHAR(13) +  'DELETE FROM Multilinguismo WHERE IdMultilng = ''' + @IdMultilng + ''''
SET @sqlCMD =  @sqlCMD + CHAR(13) +  'IF NOT EXISTS (SELECT * FROM Multilinguismo WHERE IdMultilng = ''' + @IdMultilng + ''')'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  'BEGIN'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '         INSERT INTO Multilinguismo (IdMultilng, mlngDesc_I, mlngDesc_UK, mlngDesc_E, mlngDesc_FRA)'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '                 VALUES (''' + @IdMultilng + ''', ' + @mlngDesc_I + ', ' + @mlngDesc_UK + ', ' + @mlngDesc_E + ', ' + @mlngDesc_FRA+ ')'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '         IF @@ERROR <> 0'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '         BEGIN'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '                 RAISERROR(''Errore "INSERT" Multilinguismo'', 16, 1)'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '                 ROLLBACK TRAN'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '                 RETURN'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  '         END'
SET @sqlCMD =  @sqlCMD + CHAR(13) +  'END'

IF @ommit_tran = 0
BEGIN
        SET @sqlCMD =  @sqlCMD + CHAR(13) + 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        SET @sqlCMD =  @sqlCMD + CHAR(13) + 'SET NOCOUNT OFF'
END


SELECT @sqlCMD AS Script




GO
