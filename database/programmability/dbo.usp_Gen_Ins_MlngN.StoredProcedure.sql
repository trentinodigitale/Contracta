USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_MlngN]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Gen_Ins_MlngN] (
  @ml_Key VARCHAR(400)
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)

AS

DECLARE @ml_Description                    VARCHAR(8000)
DECLARE @ml_Context                        VARCHAR(8000)
DECLARE @ml_Lng                            VARCHAR(8000)
DECLARE @ml_Module                         VARCHAR(8000)

SET @ml_Key = RTRIM(@ml_Key)

IF NOT EXISTS (SELECT * FROM LIB_Multilinguismo WHERE ml_Key = @ml_Key)
BEGIN
        RAISERROR ('Chiave [%s] non trovata', 16, 1, @ml_Key)
        RETURN 99
END

SELECT @ml_Description   = CASE WHEN CAST(ml_Description   AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(ml_Description  AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
     , @ml_Context  = CASE WHEN CAST(ml_Context  AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(ml_Context  AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
     , @ml_Lng   = CASE WHEN CAST(ml_Lng   AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(ml_Lng   AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
     , @ml_Module = CASE WHEN CAST(ml_Module AS VARCHAR(8000)) IS NOT NULL 
                                THEN '''' + REPLACE(CAST(ml_Module AS VARCHAR(8000)), '''', '''''')  + '''' ELSE 'NULL' END
  FROM LIB_Multilinguismo
 WHERE ml_Key = @ml_Key
 
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
PRINT 'IF NOT EXISTS (SELECT * FROM LIB_Multilinguismo WHERE ml_Key = ''' + REPLACE(@ml_Key, '''', '''''') + ''')'
PRINT 'BEGIN'
PRINT '         INSERT INTO LIB_Multilinguismo (ml_Key, ml_Description, ml_Context, ml_Lng, ml_Module)'
PRINT '                 VALUES (''' + REPLACE(@ml_Key, '''', '''''') + ''', ' + @ml_Description + ', ' + @ml_Context + ', ' + @ml_Lng + ', ' + @ml_Module+ ')'
PRINT ' '
PRINT '         IF @@ERROR <> 0'
PRINT '         BEGIN'
PRINT '                 RAISERROR(''Errore "INSERT" LIB_Multilinguismo'', 16, 1)'
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
